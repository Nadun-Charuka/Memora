import 'package:cloud_firestore/cloud_firestore.dart';

// Tree growth stages
enum TreeStage {
  notPlanted, // Initial state - waiting for both partners
  seedling, // 0-5 memories
  growing, // 6-15 memories
  blooming, // 16-30 memories
  mature; // 31+ memories

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
    }
  }
}

// Memory emotion types
enum MemoryEmotion {
  happy, // Flower 🌸
  excited, // Bird 🐦
  joyful, // Fruit 🍎
  grateful, // Star ⭐
  love, // Heart ❤️
  sad, // Rain 💧
  nostalgic, // Butterfly 🦋
  peaceful; // Leaf 🍃

  String get icon {
    switch (this) {
      case MemoryEmotion.happy:
        return '🌸';
      case MemoryEmotion.excited:
        return '🐦';
      case MemoryEmotion.joyful:
        return '🍎';
      case MemoryEmotion.grateful:
        return '⭐';
      case MemoryEmotion.love:
        return '❤️';
      case MemoryEmotion.sad:
        return '💧';
      case MemoryEmotion.nostalgic:
        return '🦋';
      case MemoryEmotion.peaceful:
        return '🍃';
    }
  }

  String get displayName {
    switch (this) {
      case MemoryEmotion.happy:
        return 'Happy';
      case MemoryEmotion.excited:
        return 'Excited';
      case MemoryEmotion.joyful:
        return 'Joyful';
      case MemoryEmotion.grateful:
        return 'Grateful';
      case MemoryEmotion.love:
        return 'Love';
      case MemoryEmotion.sad:
        return 'Sad';
      case MemoryEmotion.nostalgic:
        return 'Nostalgic';
      case MemoryEmotion.peaceful:
        return 'Peaceful';
    }
  }
}

// Memory/Memo model
class Memory {
  final String id;
  final String content;
  final MemoryEmotion emotion;
  final String? photoUrl;
  final String addedBy;
  final String addedByName;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.content,
    required this.emotion,
    this.photoUrl,
    required this.addedBy,
    required this.addedByName,
    required this.createdAt,
  });

  factory Memory.fromFirestore(Map<String, dynamic> data, String id) {
    return Memory(
      id: id,
      content: data['content'] ?? '',
      emotion: MemoryEmotion.values.firstWhere(
        (e) => e.name == data['emotion'],
        orElse: () => MemoryEmotion.happy,
      ),
      photoUrl: data['photoUrl'],
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'emotion': emotion.name,
      'photoUrl': photoUrl,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

// Love Tree model
class LoveTree {
  final String id;
  final String name;
  final String type;
  final int level;
  final double height;
  final double happiness;
  final double health;
  final int lovePoints;
  final TreeStage stage;
  final int memoryCount;
  final bool isPlanted;
  final DateTime createdAt;
  final DateTime lastInteraction;
  final List<Memory> memories;

  LoveTree({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.height,
    required this.happiness,
    required this.health,
    required this.lovePoints,
    required this.stage,
    required this.memoryCount,
    required this.isPlanted,
    required this.createdAt,
    required this.lastInteraction,
    this.memories = const [],
  });

  factory LoveTree.fromFirestore(Map<String, dynamic> data, String id) {
    return LoveTree(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'DefaultTree',
      level: data['level'] ?? 1,
      height: (data['height'] ?? 10.0).toDouble(),
      happiness: (data['happiness'] ?? 1.0).toDouble(),
      health: (data['health'] ?? 1.0).toDouble(),
      lovePoints: data['lovePoints'] ?? 0,
      stage: _stageFromString(data['stage']),
      memoryCount: data['memoryCount'] ?? 0,
      isPlanted: data['isPlanted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastInteraction:
          (data['lastInteraction'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memories: [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'level': level,
      'height': height,
      'happiness': happiness,
      'health': health,
      'lovePoints': lovePoints,
      'stage': stage.name,
      'memoryCount': memoryCount,
      'isPlanted': isPlanted,
      'lastInteraction': FieldValue.serverTimestamp(),
    };
  }

  static TreeStage _stageFromString(String? stage) {
    return TreeStage.values.firstWhere(
      (s) => s.name == stage,
      orElse: () => TreeStage.notPlanted,
    );
  }

  // Calculate stage based on memory count
  static TreeStage calculateStage(int memoryCount, bool isPlanted) {
    if (!isPlanted) return TreeStage.notPlanted;
    if (memoryCount <= 5) return TreeStage.seedling;
    if (memoryCount <= 15) return TreeStage.growing;
    if (memoryCount <= 30) return TreeStage.blooming;
    return TreeStage.mature;
  }

  // Get progress percentage for current stage
  double get stageProgress {
    if (!isPlanted) return 0.0;
    switch (stage) {
      case TreeStage.notPlanted:
        return 0.0;
      case TreeStage.seedling:
        return (memoryCount / 5).clamp(0.0, 1.0);
      case TreeStage.growing:
        return ((memoryCount - 5) / 10).clamp(0.0, 1.0);
      case TreeStage.blooming:
        return ((memoryCount - 15) / 15).clamp(0.0, 1.0);
      case TreeStage.mature:
        return 1.0;
    }
  }

  // Copy with updated values
  LoveTree copyWith({
    String? id,
    String? name,
    String? type,
    int? level,
    double? height,
    double? happiness,
    double? health,
    int? lovePoints,
    TreeStage? stage,
    int? memoryCount,
    bool? isPlanted,
    DateTime? createdAt,
    DateTime? lastInteraction,
    List<Memory>? memories,
  }) {
    return LoveTree(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      level: level ?? this.level,
      height: height ?? this.height,
      happiness: happiness ?? this.happiness,
      health: health ?? this.health,
      lovePoints: lovePoints ?? this.lovePoints,
      stage: stage ?? this.stage,
      memoryCount: memoryCount ?? this.memoryCount,
      isPlanted: isPlanted ?? this.isPlanted,
      createdAt: createdAt ?? this.createdAt,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      memories: memories ?? this.memories,
    );
  }
}
