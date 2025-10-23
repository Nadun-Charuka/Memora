import 'package:cloud_firestore/cloud_firestore.dart';

enum TreeStage {
  notPlanted,
  seedling,
  growing,
  blooming,
  mature,
  completed; // NEW: When 60 memories reached

  String get displayName {
    switch (this) {
      case TreeStage.notPlanted:
        return 'Not Planted';
      case TreeStage.seedling:
        return 'Seedling';
      case TreeStage.growing:
        return 'Growing';
      case TreeStage.blooming:
        return 'Blooming';
      case TreeStage.mature:
        return 'Mature Tree';
      case TreeStage.completed:
        return 'Completed';
    }
  }
}

class LoveTree {
  final String id; // Format: "YYYY_MM"
  final String villageId;
  final String name;
  final String type;
  final int level;
  final double height;
  final double happiness;
  final int lovePoints;
  final TreeStage stage;
  final int memoryCount;
  final bool isPlanted;
  final List<String> plantedBy;
  final DateTime createdAt;
  final DateTime lastInteraction;
  final DateTime? completedAt;
  final int maxMemories; // NEW: Make it dynamic per tree

  LoveTree({
    required this.id,
    required this.villageId,
    required this.name,
    required this.type,
    required this.level,
    required this.height,
    required this.happiness,
    required this.lovePoints,
    required this.stage,
    required this.memoryCount,
    required this.isPlanted,
    required this.plantedBy,
    required this.createdAt,
    required this.lastInteraction,
    this.completedAt,
    int? maxMemories, // NEW: Optional parameter
  }) : maxMemories = maxMemories ?? _calculateMaxMemories(id);

  // NEW: Calculate max memories based on month
  static int _calculateMaxMemories(String monthKey) {
    try {
      final parts = monthKey.split('_');
      if (parts.length != 2) return 62;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // Get days in month
      final daysInMonth = DateTime(year, month + 1, 0).day;
      return daysInMonth * 2; // 2 memories per day
    } catch (e) {
      return 62; // Fallback to max
    }
  }

  bool get isCompleted => stage == TreeStage.completed;
  bool get canAddMemories => isPlanted && !isCompleted;
  int get remainingMemories => maxMemories - memoryCount;

  factory LoveTree.fromFirestore(Map<String, dynamic> data, String id) {
    return LoveTree(
      id: id,
      villageId: data['villageId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'DefaultTree',
      level: data['level'] ?? 1,
      height: (data['height'] ?? 10.0).toDouble(),
      happiness: (data['happiness'] ?? 1.0).toDouble(),
      lovePoints: data['lovePoints'] ?? 0,
      stage: _stageFromString(data['stage']),
      memoryCount: data['memoryCount'] ?? 0,
      isPlanted: data['isPlanted'] ?? false,
      plantedBy: List<String>.from(data['plantedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastInteraction:
          (data['lastInteraction'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      maxMemories: data['maxMemories'], // NEW: Load from Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'villageId': villageId,
      'name': name,
      'type': type,
      'level': level,
      'height': height,
      'happiness': happiness,
      'lovePoints': lovePoints,
      'stage': stage.name,
      'memoryCount': memoryCount,
      'isPlanted': isPlanted,
      'plantedBy': plantedBy,
      'maxMemories': maxMemories, // NEW: Save to Firestore
      'lastInteraction': FieldValue.serverTimestamp(),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  static TreeStage _stageFromString(String? stage) {
    return TreeStage.values.firstWhere(
      (s) => s.name == stage,
      orElse: () => TreeStage.notPlanted,
    );
  }

  // Keep static method for backward compatibility
  static TreeStage calculateStage(
    int memoryCount,
    bool isPlanted,
    int maxMemories,
  ) {
    if (!isPlanted) return TreeStage.notPlanted;
    if (memoryCount >= maxMemories) return TreeStage.completed;
    if (memoryCount <= 10) return TreeStage.seedling;
    if (memoryCount <= 25) return TreeStage.growing;
    if (memoryCount <= 40) return TreeStage.blooming;
    return TreeStage.mature;
  }

  double get stageProgress {
    if (!isPlanted) return 0.0;
    if (isCompleted) return 1.0;
    return (memoryCount / maxMemories).clamp(0.0, 1.0);
  }
}
