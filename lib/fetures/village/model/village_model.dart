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
  });

  bool get isActive => status == VillageStatus.active && partner2Id != null;
  bool get isPending => status == VillageStatus.pending || partner2Id == null;

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
      lastInteraction:
          (data['lastInteraction'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

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
      'lastInteraction': FieldValue.serverTimestamp(),
    };
  }
}

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
}
