import 'package:cloud_firestore/cloud_firestore.dart';

enum TreeStage {
  notPlanted,
  seedling, // 0-5 memories
  sprouting, // 5-10 memories
  growing, // 10-18 memories
  flourishing, // 18-28 memories
  blooming, // 28-38 memories
  radiant, // 38-48 memories
  mature, // 48-58 memories
  completed; // 58+ memories

  String get displayName {
    switch (this) {
      case TreeStage.notPlanted:
        return 'Not Planted';
      case TreeStage.seedling:
        return 'Seedling';
      case TreeStage.sprouting:
        return 'Sprouting';
      case TreeStage.growing:
        return 'Growing';
      case TreeStage.flourishing:
        return 'Flourishing';
      case TreeStage.blooming:
        return 'Blooming';
      case TreeStage.radiant:
        return 'Radiant Bloom';
      case TreeStage.mature:
        return 'Mature Tree';
      case TreeStage.completed:
        return 'Completed';
    }
  }

  String get emoji {
    switch (this) {
      case TreeStage.notPlanted:
        return '🌱';
      case TreeStage.seedling:
        return '🌱';
      case TreeStage.sprouting:
        return '🌿';
      case TreeStage.growing:
        return '🌿';
      case TreeStage.flourishing:
        return '🍃';
      case TreeStage.blooming:
        return '🌸';
      case TreeStage.radiant:
        return '✨';
      case TreeStage.mature:
        return '🌳';
      case TreeStage.completed:
        return '🎉';
    }
  }
}

class LoveTree {
  final String id;
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
  final int maxMemories;

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
    int? maxMemories,
  }) : maxMemories = maxMemories ?? _calculateMaxMemories(id);

  static int _calculateMaxMemories(String monthKey) {
    try {
      final parts = monthKey.split('_');
      if (parts.length != 2) return 60;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final daysInMonth = DateTime(year, month + 1, 0).day;
      return daysInMonth * 2;
    } catch (e) {
      return 60;
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
      maxMemories: data['maxMemories'],
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
      'maxMemories': maxMemories,
      'createdAt': FieldValue.serverTimestamp(),
      'lastInteraction': FieldValue.serverTimestamp(),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  Map<String, dynamic> toFirestoreUpdate() {
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
      'maxMemories': maxMemories,
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

  /// Calculate stage based on memory count with new stages
  static TreeStage calculateStage(
    int memoryCount,
    bool isPlanted,
    int maxMemories,
  ) {
    if (!isPlanted) return TreeStage.notPlanted;
    if (memoryCount >= maxMemories) return TreeStage.completed;
    if (memoryCount <= 5) return TreeStage.seedling;
    if (memoryCount <= 10) return TreeStage.sprouting;
    if (memoryCount <= 18) return TreeStage.growing;
    if (memoryCount <= 28) return TreeStage.flourishing;
    if (memoryCount <= 38) return TreeStage.blooming;
    if (memoryCount <= 48) return TreeStage.radiant;
    return TreeStage.mature;
  }

  double get stageProgress {
    if (!isPlanted) return 0.0;
    if (isCompleted) return 1.0;
    return (memoryCount / maxMemories).clamp(0.0, 1.0);
  }

  /// Get progress within current stage (for animations)
  double get stageLocalProgress {
    if (!isPlanted || isCompleted) return 1.0;

    final ranges = {
      TreeStage.seedling: (0, 5),
      TreeStage.sprouting: (5, 10),
      TreeStage.growing: (10, 18),
      TreeStage.flourishing: (18, 28),
      TreeStage.blooming: (28, 38),
      TreeStage.radiant: (38, 48),
      TreeStage.mature: (48, 58),
    };

    final range = ranges[stage];
    if (range == null) return 1.0;

    final (min, max) = range;
    final localCount = memoryCount - min;
    final stageSize = max - min;

    return (localCount / stageSize).clamp(0.0, 1.0);
  }
}
