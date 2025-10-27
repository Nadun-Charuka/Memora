import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service to handle streak calculation and management
class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check and update streak after a memory is added
  /// This should be called after successful memory addition
  Future<StreakResult> updateStreakAfterMemory({
    required String villageId,
    required String userId,
  }) async {
    try {
      final villageRef = _firestore.collection('villages').doc(villageId);
      final villageDoc = await villageRef.get();

      if (!villageDoc.exists) {
        return StreakResult(success: false, message: 'Village not found');
      }

      final data = villageDoc.data()!;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get streak data
      final currentStreak = data['currentStreak'] ?? 0;
      final maxStreak = data['maxStreak'] ?? 0;
      final lastContributionDate = (data['lastContributionDate'] as Timestamp?)
          ?.toDate();
      final partner1Id = data['partner1Id'] as String;
      final partner2Id = data['partner2Id'] as String?;

      // Get last contribution dates for each partner
      final lastContrib1 = (data['partner1LastContribution'] as Timestamp?)
          ?.toDate();
      final lastContrib2 = (data['partner2LastContribution'] as Timestamp?)
          ?.toDate();

      // Update the contributor's last contribution date
      final updates = <String, dynamic>{};
      if (userId == partner1Id) {
        updates['partner1LastContribution'] = FieldValue.serverTimestamp();
      } else if (userId == partner2Id) {
        updates['partner2LastContribution'] = FieldValue.serverTimestamp();
      }

      // Calculate new streak
      int newStreak = currentStreak;
      bool streakIncreased = false;
      String message = '';

      if (partner2Id == null) {
        // Village not complete yet, don't count streak
        message = 'Waiting for partner to join';
      } else if (lastContributionDate == null) {
        // First ever contribution to the village
        newStreak = 1;
        streakIncreased = true;
        message = '🔥 Day 1 streak started!';
      } else {
        final lastContribDay = DateTime(
          lastContributionDate.year,
          lastContributionDate.month,
          lastContributionDate.day,
        );

        // Check if this is a new day contribution
        if (today.isAfter(lastContribDay)) {
          final daysDifference = today.difference(lastContribDay).inDays;

          if (daysDifference == 1) {
            // Consecutive day - check if BOTH partners contributed
            final bothContributed = _checkBothPartnersContributed(
              partner1Id: partner1Id,
              partner2Id: partner2Id,
              userId: userId,
              lastContrib1: lastContrib1,
              lastContrib2: lastContrib2,
              today: today,
            );

            if (bothContributed) {
              newStreak = currentStreak + 1;
              streakIncreased = true;
              message = '🔥 Streak continued! Day $newStreak';
            } else {
              message = '⏳ Waiting for partner to contribute today';
            }
          } else if (daysDifference > 1) {
            // Streak broken - restart
            newStreak = 1;
            message = '💔 Streak reset. Starting fresh! Day 1';
          }
        } else {
          // Same day, different user
          message = 'Already contributed today';
        }
      }

      // Update village document
      updates['currentStreak'] = newStreak;
      updates['lastContributionDate'] = FieldValue.serverTimestamp();

      if (newStreak > maxStreak) {
        updates['maxStreak'] = newStreak;
        message += ' 🎉 New record!';
      }

      await villageRef.update(updates);

      return StreakResult(
        success: true,
        message: message,
        currentStreak: newStreak,
        maxStreak: newStreak > maxStreak ? newStreak : maxStreak,
        streakIncreased: streakIncreased,
      );
    } catch (e) {
      debugPrint('Error updating streak: $e');
      return StreakResult(success: false, message: 'Error updating streak');
    }
  }

  /// Check if both partners have contributed today/yesterday
  bool _checkBothPartnersContributed({
    required String partner1Id,
    required String partner2Id,
    required String userId,
    required DateTime? lastContrib1,
    required DateTime? lastContrib2,
    required DateTime today,
  }) {
    if (lastContrib1 == null || lastContrib2 == null) return false;

    final yesterday = today.subtract(const Duration(days: 1));

    // Normalize dates (remove time)
    final contrib1Day = DateTime(
      lastContrib1.year,
      lastContrib1.month,
      lastContrib1.day,
    );
    final contrib2Day = DateTime(
      lastContrib2.year,
      lastContrib2.month,
      lastContrib2.day,
    );

    // Check if one contributed today and other yesterday or both yesterday
    if (userId == partner1Id) {
      // Current user (partner1) is contributing today
      // Check if partner2 contributed yesterday or today
      return contrib2Day.isAtSameMomentAs(yesterday) ||
          contrib2Day.isAtSameMomentAs(today);
    } else {
      // Current user (partner2) is contributing today
      // Check if partner1 contributed yesterday or today
      return contrib1Day.isAtSameMomentAs(yesterday) ||
          contrib1Day.isAtSameMomentAs(today);
    }
  }

  /// Check streak status and potentially break it
  /// This should run daily (via Cloud Functions or on app open)
  Future<void> checkAndBreakStreak(String villageId) async {
    try {
      final villageRef = _firestore.collection('villages').doc(villageId);
      final villageDoc = await villageRef.get();

      if (!villageDoc.exists) return;

      final data = villageDoc.data()!;
      final currentStreak = data['currentStreak'] ?? 0;

      if (currentStreak == 0) return; // No active streak

      final lastContribDate = (data['lastContributionDate'] as Timestamp?)
          ?.toDate();

      if (lastContribDate == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(
        lastContribDate.year,
        lastContribDate.month,
        lastContribDate.day,
      );

      final daysSinceLastContrib = today.difference(lastDay).inDays;

      // Break streak if more than 1 day passed
      if (daysSinceLastContrib > 1) {
        await villageRef.update({
          'currentStreak': 0,
          'streakBrokenAt': FieldValue.serverTimestamp(),
        });

        debugPrint(
          'Streak broken for village $villageId after $daysSinceLastContrib days',
        );
      }
    } catch (e) {
      debugPrint('Error checking streak: $e');
    }
  }

  /// Get current streak info
  Future<StreakInfo?> getStreakInfo(String villageId) async {
    try {
      final villageDoc = await _firestore
          .collection('villages')
          .doc(villageId)
          .get();

      if (!villageDoc.exists) return null;

      final data = villageDoc.data()!;

      return StreakInfo(
        currentStreak: data['currentStreak'] ?? 0,
        maxStreak: data['maxStreak'] ?? 0,
        lastContributionDate: (data['lastContributionDate'] as Timestamp?)
            ?.toDate(),
        partner1LastContribution:
            (data['partner1LastContribution'] as Timestamp?)?.toDate(),
        partner2LastContribution:
            (data['partner2LastContribution'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if streak is in danger (neither partner contributed today)
  Future<bool> isStreakInDanger(String villageId) async {
    try {
      final info = await getStreakInfo(villageId);
      if (info == null || info.currentStreak == 0) return false;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final lastContrib1Day = info.partner1LastContribution != null
          ? DateTime(
              info.partner1LastContribution!.year,
              info.partner1LastContribution!.month,
              info.partner1LastContribution!.day,
            )
          : null;

      final lastContrib2Day = info.partner2LastContribution != null
          ? DateTime(
              info.partner2LastContribution!.year,
              info.partner2LastContribution!.month,
              info.partner2LastContribution!.day,
            )
          : null;

      // Danger if both partners haven't contributed today
      final partner1ContributedToday =
          lastContrib1Day?.isAtSameMomentAs(today) ?? false;
      final partner2ContributedToday =
          lastContrib2Day?.isAtSameMomentAs(today) ?? false;

      return !partner1ContributedToday && !partner2ContributedToday;
    } catch (e) {
      return false;
    }
  }
}

/// Result of streak update operation
class StreakResult {
  final bool success;
  final String message;
  final int currentStreak;
  final int maxStreak;
  final bool streakIncreased;

  StreakResult({
    required this.success,
    required this.message,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.streakIncreased = false,
  });
}

/// Information about current streak status
class StreakInfo {
  final int currentStreak;
  final int maxStreak;
  final DateTime? lastContributionDate;
  final DateTime? partner1LastContribution;
  final DateTime? partner2LastContribution;

  StreakInfo({
    required this.currentStreak,
    required this.maxStreak,
    this.lastContributionDate,
    this.partner1LastContribution,
    this.partner2LastContribution,
  });

  bool get hasActiveStreak => currentStreak > 0;

  bool didPartner1ContributeToday() {
    if (partner1LastContribution == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      partner1LastContribution!.year,
      partner1LastContribution!.month,
      partner1LastContribution!.day,
    );
    return lastDay.isAtSameMomentAs(today);
  }

  bool didPartner2ContributeToday() {
    if (partner2LastContribution == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      partner2LastContribution!.year,
      partner2LastContribution!.month,
      partner2LastContribution!.day,
    );
    return lastDay.isAtSameMomentAs(today);
  }
}
