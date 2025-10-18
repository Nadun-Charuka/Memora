import 'package:cloud_firestore/cloud_firestore.dart';

enum TreeStage { seedling, growing, blooming, mature, withering }

enum TreeMood { happy, neutral, sad, sick, thriving }

class LoveTree {
  final String id;
  final String coupleId;
  final String name;
  final String type; // 'SakuraTree', 'RoseTree', 'MapleTree'
  final DateTime createdAt;
  final String monthYear; // '2025_10'

  // Growth metrics
  double height;
  int level;
  int lovePoints;
  double happiness; // 0.0 to 1.0
  double health; // 0.0 to 1.0
  DateTime lastInteraction;

  // Computed properties
  TreeStage get stage => _calculateStage();
  TreeMood get mood => _calculateMood();

  LoveTree({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.monthYear,
    this.height = 10.0,
    this.level = 1,
    this.lovePoints = 0,
    this.happiness = 0.5,
    this.health = 1.0,
    required this.lastInteraction,
  });

  // Growth logic
  void grow(double amount) {
    height += amount;
    level = (height / 20).floor() + 1;
    lastInteraction = DateTime.now();
  }

  void addLovePoints(int points) {
    lovePoints += points;
    happiness = (happiness + 0.05).clamp(0.0, 1.0);
    health = (health + 0.02).clamp(0.0, 1.0);
  }

  void decay() {
    final daysSinceInteraction = DateTime.now()
        .difference(lastInteraction)
        .inDays;
    if (daysSinceInteraction > 3) {
      health = (health - 0.01 * daysSinceInteraction).clamp(0.0, 1.0);
    }
  }

  TreeStage _calculateStage() {
    if (health < 0.3) return TreeStage.withering;
    if (level >= 10) return TreeStage.mature;
    if (level >= 6) return TreeStage.blooming;
    if (level >= 3) return TreeStage.growing;
    return TreeStage.seedling;
  }

  TreeMood _calculateMood() {
    if (health < 0.3) return TreeMood.sick;
    if (happiness > 0.8 && health > 0.8) return TreeMood.thriving;
    if (happiness > 0.6) return TreeMood.happy;
    if (happiness < 0.4) return TreeMood.sad;
    return TreeMood.neutral;
  }

  // Firestore conversion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coupleId': coupleId,
      'name': name,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'monthYear': monthYear,
      'height': height,
      'level': level,
      'lovePoints': lovePoints,
      'happiness': happiness,
      'health': health,
      'lastInteraction': Timestamp.fromDate(lastInteraction),
    };
  }

  factory LoveTree.fromMap(Map<String, dynamic> map) {
    return LoveTree(
      id: map['id'],
      coupleId: map['coupleId'],
      name: map['name'],
      type: map['type'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      monthYear: map['monthYear'],
      height: map['height'].toDouble(),
      level: map['level'],
      lovePoints: map['lovePoints'],
      happiness: map['happiness'].toDouble(),
      health: map['health'].toDouble(),
      lastInteraction: (map['lastInteraction'] as Timestamp).toDate(),
    );
  }
}
