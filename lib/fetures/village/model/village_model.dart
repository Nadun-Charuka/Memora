import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a couple's shared village/world
class Village {
  final String id;
  final String name;
  final String partner1Id;
  final String partner1Name;
  final String? partner2Id;
  final String? partner2Name;
  final String inviteCode;
  final VillageStatus status;
  final DateTime createdAt;
  final int totalLovePoints;
  final int currentStreak;
  final DateTime lastInteraction;
  final int maxStreak;
  final DateTime? partner1LastContribution;
  final DateTime? partner2LastContribution;
  final DateTime? lastContributionDate;
  final DateTime? streakBrokenAt;
  final DateTime? joinedAt;

  Village({
    required this.id,
    required this.name,
    required this.partner1Id,
    required this.partner1Name,
    this.partner2Id,
    this.partner2Name,
    required this.inviteCode,
    required this.status,
    required this.createdAt,
    required this.totalLovePoints,
    required this.currentStreak,
    required this.lastInteraction,
    this.maxStreak = 0,
    this.partner1LastContribution,
    this.partner2LastContribution,
    this.lastContributionDate,
    this.streakBrokenAt,
    this.joinedAt,
  });

  // Computed properties
  bool get isActive => status == VillageStatus.active && partner2Id != null;
  bool get isPending => status == VillageStatus.pending || partner2Id == null;
  bool get hasActiveStreak => currentStreak > 0;

  /// Check if partner1 contributed today
  bool get didPartner1ContributeToday {
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

  /// Check if partner2 contributed today
  bool get didPartner2ContributeToday {
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

  /// Check if streak is in danger (no one contributed today)
  bool get isStreakInDanger {
    if (!hasActiveStreak) return false;
    return !didPartner1ContributeToday && !didPartner2ContributeToday;
  }

  /// Check if specific user contributed today
  bool didUserContributeToday(String userId) {
    if (userId == partner1Id) {
      return didPartner1ContributeToday;
    } else if (userId == partner2Id) {
      return didPartner2ContributeToday;
    }
    return false;
  }

  /// Get days since village was created
  int get daysActive {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get streak achievement level
  StreakLevel get streakLevel {
    if (currentStreak >= 100) return StreakLevel.legendary;
    if (currentStreak >= 50) return StreakLevel.master;
    if (currentStreak >= 30) return StreakLevel.dedicated;
    if (currentStreak >= 14) return StreakLevel.committed;
    if (currentStreak >= 7) return StreakLevel.promising;
    if (currentStreak >= 3) return StreakLevel.starting;
    return StreakLevel.newbie;
  }

  /// Create from Firestore document
  factory Village.fromFirestore(Map<String, dynamic> data, String id) {
    return Village(
      id: id,
      name: data['villageName'] ?? '',
      partner1Id: data['partner1Id'] ?? '',
      partner1Name: data['partner1Name'] ?? '',
      partner2Id: data['partner2Id'],
      partner2Name: data['partner2Name'],
      inviteCode: data['inviteCode'] ?? '',
      status: VillageStatus.fromString(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalLovePoints: data['totalLovePoints'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      maxStreak: data['maxStreak'] ?? 0,
      lastInteraction:
          (data['lastInteraction'] as Timestamp?)?.toDate() ?? DateTime.now(),
      partner1LastContribution: (data['partner1LastContribution'] as Timestamp?)
          ?.toDate(),
      partner2LastContribution: (data['partner2LastContribution'] as Timestamp?)
          ?.toDate(),
      lastContributionDate: (data['lastContributionDate'] as Timestamp?)
          ?.toDate(),
      streakBrokenAt: (data['streakBrokenAt'] as Timestamp?)?.toDate(),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'villageName': name,
      'partner1Id': partner1Id,
      'partner1Name': partner1Name,
      'partner2Id': partner2Id,
      'partner2Name': partner2Name,
      'inviteCode': inviteCode,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalLovePoints': totalLovePoints,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'lastInteraction': FieldValue.serverTimestamp(),
      if (partner1LastContribution != null)
        'partner1LastContribution': Timestamp.fromDate(
          partner1LastContribution!,
        ),
      if (partner2LastContribution != null)
        'partner2LastContribution': Timestamp.fromDate(
          partner2LastContribution!,
        ),
      if (lastContributionDate != null)
        'lastContributionDate': Timestamp.fromDate(lastContributionDate!),
      if (streakBrokenAt != null)
        'streakBrokenAt': Timestamp.fromDate(streakBrokenAt!),
      if (joinedAt != null) 'joinedAt': Timestamp.fromDate(joinedAt!),
    };
  }

  /// Create a copy with updated fields
  Village copyWith({
    String? id,
    String? name,
    String? partner1Id,
    String? partner1Name,
    String? partner2Id,
    String? partner2Name,
    String? inviteCode,
    VillageStatus? status,
    DateTime? createdAt,
    int? totalLovePoints,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastInteraction,
    DateTime? partner1LastContribution,
    DateTime? partner2LastContribution,
    DateTime? lastContributionDate,
    DateTime? streakBrokenAt,
    DateTime? joinedAt,
  }) {
    return Village(
      id: id ?? this.id,
      name: name ?? this.name,
      partner1Id: partner1Id ?? this.partner1Id,
      partner1Name: partner1Name ?? this.partner1Name,
      partner2Id: partner2Id ?? this.partner2Id,
      partner2Name: partner2Name ?? this.partner2Name,
      inviteCode: inviteCode ?? this.inviteCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      totalLovePoints: totalLovePoints ?? this.totalLovePoints,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      partner1LastContribution:
          partner1LastContribution ?? this.partner1LastContribution,
      partner2LastContribution:
          partner2LastContribution ?? this.partner2LastContribution,
      lastContributionDate: lastContributionDate ?? this.lastContributionDate,
      streakBrokenAt: streakBrokenAt ?? this.streakBrokenAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

/// Village status enum
enum VillageStatus {
  pending,
  active,
  archived;

  String get value => name;

  static VillageStatus fromString(String? status) {
    return VillageStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => VillageStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case VillageStatus.pending:
        return 'Waiting for Partner';
      case VillageStatus.active:
        return 'Active';
      case VillageStatus.archived:
        return 'Archived';
    }
  }

  String get icon {
    switch (this) {
      case VillageStatus.pending:
        return '⏳';
      case VillageStatus.active:
        return '✨';
      case VillageStatus.archived:
        return '📦';
    }
  }
}

/// Streak achievement levels
enum StreakLevel {
  newbie,
  starting,
  promising,
  committed,
  dedicated,
  master,
  legendary;

  String get displayName {
    switch (this) {
      case StreakLevel.newbie:
        return 'Getting Started';
      case StreakLevel.starting:
        return 'On Fire';
      case StreakLevel.promising:
        return 'Promising';
      case StreakLevel.committed:
        return 'Committed';
      case StreakLevel.dedicated:
        return 'Dedicated';
      case StreakLevel.master:
        return 'Master';
      case StreakLevel.legendary:
        return 'Legendary';
    }
  }

  String get icon {
    switch (this) {
      case StreakLevel.newbie:
        return '🌱';
      case StreakLevel.starting:
        return '🔥';
      case StreakLevel.promising:
        return '⭐';
      case StreakLevel.committed:
        return '💪';
      case StreakLevel.dedicated:
        return '🏆';
      case StreakLevel.master:
        return '👑';
      case StreakLevel.legendary:
        return '🌟';
    }
  }

  String get description {
    switch (this) {
      case StreakLevel.newbie:
        return 'Just getting started!';
      case StreakLevel.starting:
        return '3-6 days strong';
      case StreakLevel.promising:
        return '7-13 days of dedication';
      case StreakLevel.committed:
        return '2 weeks of love';
      case StreakLevel.dedicated:
        return 'A full month together';
      case StreakLevel.master:
        return '50+ days of memories';
      case StreakLevel.legendary:
        return '100+ days! Incredible!';
    }
  }

  int get minDays {
    switch (this) {
      case StreakLevel.newbie:
        return 0;
      case StreakLevel.starting:
        return 3;
      case StreakLevel.promising:
        return 7;
      case StreakLevel.committed:
        return 14;
      case StreakLevel.dedicated:
        return 30;
      case StreakLevel.master:
        return 50;
      case StreakLevel.legendary:
        return 100;
    }
  }
}
