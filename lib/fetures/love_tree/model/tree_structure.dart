import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';

/// Information about a single branch for memory positioning
class BranchInfo {
  final Offset startPoint;
  final Offset endPoint;
  final double angle;
  final double length;

  BranchInfo({
    required this.startPoint,
    required this.endPoint,
    required this.angle,
    required this.length,
  });

  Offset get midPoint => Offset(
    (startPoint.dx + endPoint.dx) / 2,
    (startPoint.dy + endPoint.dy) / 2,
  );
}

/// Complete tree structure for memory positioning
class TreeStructureInfo {
  final TreeStage stage;
  final double trunkHeight;
  final double trunkWidth;
  final List<BranchInfo> branches;
  final Offset treeBase;

  TreeStructureInfo({
    required this.stage,
    required this.trunkHeight,
    required this.trunkWidth,
    required this.branches,
    required this.treeBase,
  });

  /// Get suitable attachment points for memories
  List<Offset> getMemoryPoints(int count) {
    if (branches.isEmpty) {
      // For seedling/not planted, use positions along the stem
      return List.generate(count, (i) {
        final t = (i + 1) / (count + 1);
        return Offset(
          treeBase.dx,
          treeBase.dy - trunkHeight * t,
        );
      });
    }

    // Use branch endpoints and midpoints
    final points = <Offset>[];
    for (final branch in branches) {
      points.add(branch.endPoint);
      if (branch.length > 50) {
        points.add(branch.midPoint);
      }
    }
    return points;
  }

  /// Get random branch endpoint
  Offset getRandomBranchEnd(int seed) {
    if (branches.isEmpty) {
      return Offset(treeBase.dx, treeBase.dy - trunkHeight * 0.7);
    }
    final index = seed % branches.length;
    return branches[index].endPoint;
  }

  /// Get crown center (for orbiting animations)
  Offset get crownCenter => Offset(
    treeBase.dx,
    treeBase.dy - trunkHeight * 0.6,
  );
}
