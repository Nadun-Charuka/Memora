import 'package:memora/fetures/love_tree/model/tree_model.dart';

/// Configuration for a single branch
class BranchConfig {
  final double heightRatio; // Position on trunk (0.0 to 1.0)
  final double length; // Branch length in pixels
  final double angle; // Angle in radians (-π to π)
  final double width; // Branch thickness
  final int leafCount; // Number of leaves on this branch
  final int twigCount; // Number of sub-twigs
  final double leafSize; // Base size for leaves

  const BranchConfig({
    required this.heightRatio,
    required this.length,
    required this.angle,
    required this.width,
    this.leafCount = 0,
    this.twigCount = 0,
    this.leafSize = 12.0,
  });

  /// Create a mirrored version of this branch (for symmetry)
  BranchConfig mirror() {
    return BranchConfig(
      heightRatio: heightRatio,
      length: length,
      angle: -angle, // Flip angle
      width: width,
      leafCount: leafCount,
      twigCount: twigCount,
      leafSize: leafSize,
    );
  }
}

/// Complete schema for a tree stage
class TreeBranchSchema {
  final TreeStage stage;
  final List<BranchConfig> branches;
  final double trunkWidthMultiplier;
  final double heightMultiplier;
  final bool hasGlow; // For special stages
  final bool hasFlowers; // Visual indicator
  final bool hasFruits; // Visual indicator

  const TreeBranchSchema({
    required this.stage,
    required this.branches,
    this.trunkWidthMultiplier = 1.0,
    this.heightMultiplier = 1.0,
    this.hasGlow = false,
    this.hasFlowers = false,
    this.hasFruits = false,
  });

  /// Get trunk width at base
  double getTrunkWidth(double baseWidth) {
    return baseWidth * trunkWidthMultiplier;
  }

  /// Get trunk height
  double getTrunkHeight(double baseHeight) {
    return baseHeight * heightMultiplier;
  }
}

/// Centralized branch definitions for all stages
class BranchSchemas {
  // Base trunk width reference
  static const double baseTrunkWidth = 18.0;

  /// Stage 1: Seedling (0-5 memories)
  /// Just sprouted, very delicate
  static const seedling = TreeBranchSchema(
    stage: TreeStage.seedling,
    trunkWidthMultiplier: 0.22,
    heightMultiplier: 2.0,
    branches: [
      // Just 2 tiny first leaves
      BranchConfig(
        heightRatio: 0.5,
        length: 8,
        angle: -0.7,
        width: 1.5,
        leafCount: 1,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.7,
        length: 8,
        angle: 0.7,
        width: 1.5,
        leafCount: 1,
        leafSize: 10,
      ),
    ],
  );

  /// Stage 2: Sprouting (5-10 memories) 🌱
  /// First real branches emerging
  static const sprouting = TreeBranchSchema(
    stage: TreeStage.sprouting,
    trunkWidthMultiplier: 0.4,
    heightMultiplier: 1.8,
    branches: [
      // Lower branches - small but defined
      BranchConfig(
        heightRatio: 0.35,
        length: 30,
        angle: -1.0,
        width: 3.0,
        leafCount: 6,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.38,
        length: 30,
        angle: 1.0,
        width: 3.0,
        leafCount: 6,
        twigCount: 1,
        leafSize: 11,
      ),
      // Middle branches
      BranchConfig(
        heightRatio: 0.55,
        length: 25,
        angle: -0.75,
        width: 2.5,
        leafCount: 5,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.58,
        length: 25,
        angle: 0.75,
        width: 2.5,
        leafCount: 5,
        leafSize: 10,
      ),
      // Top branches - reaching upward
      BranchConfig(
        heightRatio: 0.75,
        length: 20,
        angle: -0.5,
        width: 2.0,
        leafCount: 4,
        leafSize: 9,
      ),
      BranchConfig(
        heightRatio: 0.78,
        length: 20,
        angle: 0.5,
        width: 2.0,
        leafCount: 4,
        leafSize: 9,
      ),
    ],
  );

  /// Stage 3: Growing (10-18 memories) 🌿
  /// Wild, energetic growth phase
  static const growing = TreeBranchSchema(
    stage: TreeStage.growing,
    trunkWidthMultiplier: 0.65,
    heightMultiplier: 1.5,
    branches: [
      // Lower dense branches
      BranchConfig(
        heightRatio: 0.3,
        length: 55,
        angle: -1.1,
        width: 4.5,
        leafCount: 14,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.33,
        length: 48,
        angle: 0.85,
        width: 4.0,
        leafCount: 12,
        twigCount: 2,
        leafSize: 13,
      ),
      // Middle asymmetric growth
      BranchConfig(
        heightRatio: 0.48,
        length: 52,
        angle: -0.9,
        width: 3.8,
        leafCount: 13,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.51,
        length: 58,
        angle: 0.75,
        width: 4.2,
        leafCount: 15,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.62,
        length: 45,
        angle: -0.7,
        width: 3.5,
        leafCount: 11,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.65,
        length: 50,
        angle: 0.8,
        width: 3.7,
        leafCount: 12,
        twigCount: 2,
        leafSize: 11,
      ),
      // Upper branches
      BranchConfig(
        heightRatio: 0.75,
        length: 42,
        angle: -0.55,
        width: 3.2,
        leafCount: 9,
        twigCount: 1,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.78,
        length: 38,
        angle: 0.6,
        width: 3.0,
        leafCount: 8,
        twigCount: 1,
        leafSize: 10,
      ),
    ],
  );

  /// Stage 4: Flourishing (18-28 memories) 🍃
  /// Dense, vibrant foliage
  static const flourishing = TreeBranchSchema(
    stage: TreeStage.flourishing,
    trunkWidthMultiplier: 0.8,
    heightMultiplier: 1.3,
    hasGlow: true, // Subtle glow starts appearing
    branches: [
      // Dense lower canopy
      BranchConfig(
        heightRatio: 0.25,
        length: 65,
        angle: -1.05,
        width: 5.0,
        leafCount: 18,
        twigCount: 3,
        leafSize: 14,
      ),
      BranchConfig(
        heightRatio: 0.28,
        length: 65,
        angle: 1.05,
        width: 5.0,
        leafCount: 18,
        twigCount: 3,
        leafSize: 14,
      ),
      // Mid canopy - fuller
      BranchConfig(
        heightRatio: 0.4,
        length: 60,
        angle: -0.9,
        width: 4.5,
        leafCount: 16,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.43,
        length: 60,
        angle: 0.9,
        width: 4.5,
        leafCount: 16,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.55,
        length: 55,
        angle: -0.8,
        width: 4.0,
        leafCount: 14,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.58,
        length: 55,
        angle: 0.8,
        width: 4.0,
        leafCount: 14,
        twigCount: 2,
        leafSize: 12,
      ),
      // Upper canopy
      BranchConfig(
        heightRatio: 0.7,
        length: 48,
        angle: -0.65,
        width: 3.5,
        leafCount: 12,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.73,
        length: 48,
        angle: 0.65,
        width: 3.5,
        leafCount: 12,
        twigCount: 1,
        leafSize: 11,
      ),
      // Crown
      BranchConfig(
        heightRatio: 0.85,
        length: 40,
        angle: -0.4,
        width: 3.0,
        leafCount: 10,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.88,
        length: 40,
        angle: 0.4,
        width: 3.0,
        leafCount: 10,
        leafSize: 10,
      ),
    ],
  );

  /// Stage 5: Blooming (28-38 memories) 🌸
  /// Elegant with flowers appearing
  static const blooming = TreeBranchSchema(
    stage: TreeStage.blooming,
    trunkWidthMultiplier: 0.9,
    heightMultiplier: 1.2,
    hasGlow: true,
    hasFlowers: true,
    branches: [
      // Symmetric, elegant structure
      BranchConfig(
        heightRatio: 0.22,
        length: 75,
        angle: -1.1,
        width: 4.5,
        leafCount: 15,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.25,
        length: 75,
        angle: 1.1,
        width: 4.5,
        leafCount: 15,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.38,
        length: 70,
        angle: -0.95,
        width: 4.0,
        leafCount: 13,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.41,
        length: 70,
        angle: 0.95,
        width: 4.0,
        leafCount: 13,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.52,
        length: 65,
        angle: -0.85,
        width: 3.8,
        leafCount: 12,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.55,
        length: 65,
        angle: 0.85,
        width: 3.8,
        leafCount: 12,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.66,
        length: 58,
        angle: -0.75,
        width: 3.5,
        leafCount: 10,
        twigCount: 1,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.69,
        length: 58,
        angle: 0.75,
        width: 3.5,
        leafCount: 10,
        twigCount: 1,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.78,
        length: 52,
        angle: -0.65,
        width: 3.2,
        leafCount: 9,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.81,
        length: 52,
        angle: 0.65,
        width: 3.2,
        leafCount: 9,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.88,
        length: 45,
        angle: -0.5,
        width: 2.8,
        leafCount: 7,
        leafSize: 9,
      ),
      BranchConfig(
        heightRatio: 0.91,
        length: 45,
        angle: 0.5,
        width: 2.8,
        leafCount: 7,
        leafSize: 9,
      ),
    ],
  );

  /// Stage 6: Radiant (38-48 memories) ✨
  /// Peak beauty with golden highlights
  static const radiant = TreeBranchSchema(
    stage: TreeStage.radiant,
    trunkWidthMultiplier: 0.95,
    heightMultiplier: 1.15,
    hasGlow: true,
    hasFlowers: true,
    hasFruits: true,
    branches: [
      // Full, majestic structure
      BranchConfig(
        heightRatio: 0.2,
        length: 82,
        angle: -1.1,
        width: 5.5,
        leafCount: 20,
        twigCount: 3,
        leafSize: 14,
      ),
      BranchConfig(
        heightRatio: 0.22,
        length: 82,
        angle: 1.1,
        width: 5.5,
        leafCount: 20,
        twigCount: 3,
        leafSize: 14,
      ),
      BranchConfig(
        heightRatio: 0.35,
        length: 78,
        angle: -0.95,
        width: 5.0,
        leafCount: 18,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.38,
        length: 78,
        angle: 0.95,
        width: 5.0,
        leafCount: 18,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.5,
        length: 72,
        angle: -0.85,
        width: 4.5,
        leafCount: 16,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.53,
        length: 72,
        angle: 0.85,
        width: 4.5,
        leafCount: 16,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.65,
        length: 65,
        angle: -0.75,
        width: 4.0,
        leafCount: 14,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.68,
        length: 65,
        angle: 0.75,
        width: 4.0,
        leafCount: 14,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.78,
        length: 58,
        angle: -0.65,
        width: 3.5,
        leafCount: 12,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.81,
        length: 58,
        angle: 0.65,
        width: 3.5,
        leafCount: 12,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.9,
        length: 50,
        angle: -0.4,
        width: 3.0,
        leafCount: 10,
        leafSize: 9,
      ),
      BranchConfig(
        heightRatio: 0.92,
        length: 50,
        angle: 0.4,
        width: 3.0,
        leafCount: 10,
        leafSize: 9,
      ),
    ],
  );

  /// Stage 7: Mature (48-58 memories) 🌳
  /// Fully developed, strong presence
  static const mature = TreeBranchSchema(
    stage: TreeStage.mature,
    trunkWidthMultiplier: 1.0,
    heightMultiplier: 1.0,
    hasGlow: true,
    hasFlowers: true,
    hasFruits: true,
    branches: [
      BranchConfig(
        heightRatio: 0.2,
        length: 80,
        angle: -1.0,
        width: 6.0,
        leafCount: 18,
        twigCount: 3,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.22,
        length: 80,
        angle: 1.0,
        width: 6.0,
        leafCount: 18,
        twigCount: 3,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.4,
        length: 75,
        angle: -0.8,
        width: 5.0,
        leafCount: 16,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.42,
        length: 75,
        angle: 0.8,
        width: 5.0,
        leafCount: 16,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.6,
        length: 65,
        angle: -0.7,
        width: 4.5,
        leafCount: 14,
        twigCount: 2,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.62,
        length: 65,
        angle: 0.7,
        width: 4.5,
        leafCount: 14,
        twigCount: 2,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.78,
        length: 50,
        angle: -0.6,
        width: 3.5,
        leafCount: 12,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.8,
        length: 50,
        angle: 0.6,
        width: 3.5,
        leafCount: 12,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.92,
        length: 40,
        angle: 0.2,
        width: 3.0,
        leafCount: 8,
        leafSize: 9,
      ),
    ],
  );

  /// Stage 8: Completed (60 memories) 🎉
  /// Celebratory, glowing masterpiece
  static const completed = TreeBranchSchema(
    stage: TreeStage.completed,
    trunkWidthMultiplier: 1.0,
    heightMultiplier: 1.15,
    hasGlow: true,
    hasFlowers: true,
    hasFruits: true,
    branches: [
      // Same as mature but will have special effects in painter
      BranchConfig(
        heightRatio: 0.18,
        length: 90,
        angle: -1.1,
        width: 6.0,
        leafCount: 20,
        twigCount: 3,
        leafSize: 14,
      ),
      BranchConfig(
        heightRatio: 0.2,
        length: 90,
        angle: 1.1,
        width: 6.0,
        leafCount: 20,
        twigCount: 3,
        leafSize: 14,
      ),
      BranchConfig(
        heightRatio: 0.35,
        length: 85,
        angle: -0.95,
        width: 5.5,
        leafCount: 18,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.38,
        length: 85,
        angle: 0.95,
        width: 5.5,
        leafCount: 18,
        twigCount: 2,
        leafSize: 13,
      ),
      BranchConfig(
        heightRatio: 0.5,
        length: 80,
        angle: -0.85,
        width: 5.0,
        leafCount: 16,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.53,
        length: 80,
        angle: 0.85,
        width: 5.0,
        leafCount: 16,
        twigCount: 2,
        leafSize: 12,
      ),
      BranchConfig(
        heightRatio: 0.65,
        length: 72,
        angle: -0.75,
        width: 4.5,
        leafCount: 14,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.68,
        length: 72,
        angle: 0.75,
        width: 4.5,
        leafCount: 14,
        twigCount: 1,
        leafSize: 11,
      ),
      BranchConfig(
        heightRatio: 0.78,
        length: 65,
        angle: -0.65,
        width: 4.0,
        leafCount: 12,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.81,
        length: 65,
        angle: 0.65,
        width: 4.0,
        leafCount: 12,
        leafSize: 10,
      ),
      BranchConfig(
        heightRatio: 0.9,
        length: 55,
        angle: -0.4,
        width: 3.5,
        leafCount: 10,
        leafSize: 9,
      ),
      BranchConfig(
        heightRatio: 0.92,
        length: 55,
        angle: 0.4,
        width: 3.5,
        leafCount: 10,
        leafSize: 9,
      ),
      BranchConfig(
        heightRatio: 0.98,
        length: 45,
        angle: 0.0,
        width: 3.0,
        leafCount: 8,
        leafSize: 8,
      ),
    ],
  );

  /// Get schema for a specific stage
  static TreeBranchSchema getSchema(TreeStage stage) {
    switch (stage) {
      case TreeStage.notPlanted:
        return seedling; // Use seedling as template
      case TreeStage.seedling:
        return seedling;
      case TreeStage.sprouting:
        return sprouting;
      case TreeStage.growing:
        return growing;
      case TreeStage.flourishing:
        return flourishing;
      case TreeStage.blooming:
        return blooming;
      case TreeStage.radiant:
        return radiant;
      case TreeStage.mature:
        return mature;
      case TreeStage.completed:
        return completed;
    }
  }
}
