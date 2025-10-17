// Based on your proposal's growth stages [cite: 72]
enum TreeStage { seedling, growing, blooming, mature }

class LoveTree {
  final String id;
  final String name;
  final TreeStage stage;
  final int lovePoints;
  // ... other properties like health, happiness etc.

  LoveTree({
    required this.id,
    required this.name,
    required this.stage,
    required this.lovePoints,
  });

  // A method to create a copy of the object with new values.
  // This is very useful for state management.
  LoveTree copyWith({
    String? id,
    String? name,
    TreeStage? stage,
    int? lovePoints,
  }) {
    return LoveTree(
      id: id ?? this.id,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      lovePoints: lovePoints ?? this.lovePoints,
    );
  }
}
