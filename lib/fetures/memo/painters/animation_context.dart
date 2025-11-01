import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/model/tree_structure.dart';

/// Context passed to emotion painters
class AnimationContext {
  final Canvas canvas;
  final Size size;
  final double centerX;
  final double groundY;
  final double elapsedTime;
  final LoveTree tree;
  final TreeStructureInfo? treeStructure;

  AnimationContext({
    required this.canvas,
    required this.size,
    required this.centerX,
    required this.groundY,
    required this.elapsedTime,
    required this.tree,
    this.treeStructure,
  });

  double get trunkHeight {
    return tree.height *
        (tree.stage == TreeStage.seedling
            ? 2.0
            : tree.stage == TreeStage.sprouting
            ? 1.8
            : tree.stage == TreeStage.growing
            ? 1.5
            : tree.stage == TreeStage.flourishing
            ? 1.3
            : tree.stage == TreeStage.blooming
            ? 1.2
            : tree.stage == TreeStage.radiant
            ? 1.15
            : 1.0);
  }
}
