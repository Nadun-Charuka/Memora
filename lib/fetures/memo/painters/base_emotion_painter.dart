import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';

/// Position strategy for memories
enum PositionStrategy {
  branchEnds, // For flowers, fruits (attach to branches)
  orbiting, // For butterflies (orbit around tree)
  floating, // For hearts (physics-based floating)
  falling, // For raindrops (falling from sky)
  ground, // For rabbits (hopping on ground)
  sky, // For birds, stars (in the sky)
}

/// Abstract base class for all emotion painters
abstract class BaseEmotionPainter {
  /// Paint all memories of this emotion
  void paintAll(AnimationContext ctx, List<Memory> memories) {
    for (int i = 0; i < memories.length; i++) {
      paintSingle(ctx, memories[i], i, memories.length);
    }
  }

  /// Paint a single memory
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  );

  /// Get position for this memory based on strategy
  Offset getMemoryPosition(
    AnimationContext ctx,
    int index,
    int total, {
    PositionStrategy strategy = PositionStrategy.branchEnds,
    int? seed,
  }) {
    final actualSeed = seed ?? index;

    switch (strategy) {
      case PositionStrategy.branchEnds:
        return _getBranchPosition(ctx, index, total);

      case PositionStrategy.orbiting:
        return _getOrbitingPosition(ctx, index, total, actualSeed);

      case PositionStrategy.floating:
        return _getFloatingPosition(ctx, index, total, actualSeed);

      case PositionStrategy.falling:
        return _getFallingPosition(ctx, index, total);

      case PositionStrategy.ground:
        return _getGroundPosition(ctx, index, total);

      case PositionStrategy.sky:
        return _getSkyPosition(ctx, index, total);
    }
  }

  Offset _getBranchPosition(AnimationContext ctx, int index, int total) {
    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      final branches = ctx.treeStructure!.branches;
      final branchIndex = index % branches.length;
      return branches[branchIndex].endPoint;
    }

    // Fallback for seedling
    final radius = ctx.trunkHeight * 0.2;
    return Offset(
      ctx.centerX + radius * (index % 2 == 0 ? -1 : 1),
      ctx.groundY - ctx.trunkHeight * 0.7,
    );
  }

  Offset _getOrbitingPosition(
    AnimationContext ctx,
    int index,
    int total,
    int seed,
  ) {
    // Implemented in specific painters (e.g., NostalgicPainter)
    return Offset(ctx.centerX, ctx.groundY - ctx.trunkHeight * 0.6);
  }

  Offset _getFloatingPosition(
    AnimationContext ctx,
    int index,
    int total,
    int seed,
  ) {
    // Implemented in specific painters (e.g., LovePainter)
    return Offset(ctx.centerX, ctx.groundY - ctx.trunkHeight * 0.8);
  }

  Offset _getFallingPosition(AnimationContext ctx, int index, int total) {
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final y = ctx.groundY * 0.5; // Mid-screen
    return Offset(x, y);
  }

  Offset _getGroundPosition(AnimationContext ctx, int index, int total) {
    return Offset(
      (ctx.size.width / (total + 1)) * (index + 1),
      ctx.groundY,
    );
  }

  Offset _getSkyPosition(AnimationContext ctx, int index, int total) {
    return Offset(
      (ctx.size.width / (total + 1)) * (index + 1),
      60.0 + (index % 3) * 30,
    );
  }
}
