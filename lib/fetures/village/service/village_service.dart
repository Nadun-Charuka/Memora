import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memora/fetures/village/model/village_model.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';

class VillageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TreeService _treeService = TreeService();

  // Generate unique invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Create a new village with an UNPLANTED tree
  Future<VillageResult> createVillage({
    required String userId,
    required String userName,
    required String villageName,
    required String partnerName,
  }) async {
    try {
      // Generate unique invite code
      String inviteCode;
      bool codeExists = true;

      do {
        inviteCode = _generateInviteCode();
        final existing = await _firestore
            .collection('villages')
            .where('inviteCode', isEqualTo: inviteCode)
            .get();
        codeExists = existing.docs.isNotEmpty;
      } while (codeExists);

      // Create village document
      final villageRef = _firestore.collection('villages').doc();
      final village = Village(
        id: villageRef.id,
        name: villageName,
        partner1Id: userId,
        partner1Name: userName,
        partner2Name: partnerName,
        inviteCode: inviteCode,
        status: VillageStatus.pending,
        createdAt: DateTime.now(),
        totalLovePoints: 0,
        currentStreak: 0,
        lastInteraction: DateTime.now(),
      );

      await villageRef.set(village.toFirestore());

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'villageId': villageRef.id,
        'role': 'creator',
      });

      // ✨ CREATE UNPLANTED TREE
      // The tree exists in the database, but isPlanted: false
      // Both partners must press "Plant Tree" to activate it
      // This preserves the emotional moment of starting together! 🌱
      await _treeService.createMonthlyTree(villageRef.id);

      return VillageResult(
        success: true,
        villageId: villageRef.id,
        inviteCode: inviteCode,
        message: 'Village created successfully!',
      );
    } catch (e) {
      return VillageResult(
        success: false,
        message: 'Failed to create village: ${e.toString()}',
      );
    }
  }

  /// Join existing village with invite code
  Future<VillageResult> joinVillage({
    required String userId,
    required String userName,
    required String inviteCode,
  }) async {
    try {
      final villageQuery = await _firestore
          .collection('villages')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (villageQuery.docs.isEmpty) {
        return VillageResult(
          success: false,
          message: 'Invalid invite code. Please check and try again.',
        );
      }

      final villageDoc = villageQuery.docs.first;
      final villageData = villageDoc.data();

      if (villageData['partner2Id'] != null) {
        return VillageResult(
          success: false,
          message: 'This village is already complete.',
        );
      }

      if (villageData['partner1Id'] == userId) {
        return VillageResult(
          success: false,
          message: 'You cannot join your own village.',
        );
      }

      // Update village with partner 2
      await villageDoc.reference.update({
        'partner2Id': userId,
        'partner2Name': userName,
        'status': VillageStatus.active.value,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'villageId': villageDoc.id,
        'role': 'joiner',
      });

      // ✨ SAFETY CHECK: Ensure tree exists
      // Usually the tree was created when the village was made,
      // but we check just in case something went wrong
      final monthKey = _getCurrentMonthKey();
      final treeDoc = await _firestore
          .collection('villages')
          .doc(villageDoc.id)
          .collection('trees')
          .doc(monthKey)
          .get();

      if (!treeDoc.exists) {
        await _treeService.createMonthlyTree(villageDoc.id);
      }

      return VillageResult(
        success: true,
        villageId: villageDoc.id,
        message:
            'Successfully joined the village! Now both of you can plant the tree together 🌱',
      );
    } catch (e) {
      return VillageResult(
        success: false,
        message: 'Failed to join village: ${e.toString()}',
      );
    }
  }

  /// Get village by ID
  Future<Village?> getVillage(String villageId) async {
    try {
      final doc = await _firestore.collection('villages').doc(villageId).get();
      if (!doc.exists) return null;
      return Village.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Get village stream
  Stream<Village?> getVillageStream(String villageId) {
    return _firestore.collection('villages').doc(villageId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return Village.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Get user's village ID
  Future<String?> getUserVillageId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['villageId'];
    } catch (e) {
      return null;
    }
  }

  /// Update village stats (called by TreeService)
  Future<void> updateVillageStats({
    required String villageId,
    int? lovePointsIncrement,
    int? streakIncrement,
  }) async {
    final updates = <String, dynamic>{
      'lastInteraction': FieldValue.serverTimestamp(),
    };

    if (lovePointsIncrement != null) {
      updates['totalLovePoints'] = FieldValue.increment(lovePointsIncrement);
    }

    if (streakIncrement != null) {
      updates['currentStreak'] = FieldValue.increment(streakIncrement);
    }

    await _firestore.collection('villages').doc(villageId).update(updates);
  }

  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}';
  }
}

class VillageResult {
  final bool success;
  final String? villageId;
  final String? inviteCode;
  final String message;

  VillageResult({
    required this.success,
    this.villageId,
    this.inviteCode,
    required this.message,
  });
}
