import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/model/tree_structure.dart';
import 'package:memora/fetures/love_tree/painters/sky_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/blooming_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/completed_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/flourishing_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/growing_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/mature_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/radiant_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/seedling_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/sprouting_painter.dart';
import 'package:memora/fetures/love_tree/painters/stages/unplant_painter.dart';

import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/memo/painters/memory_painter.dart';

class TreePainter extends CustomPainter {
  final LoveTree tree;
  final List<Memory> memories;
  final Animation<double> animation;
  final double elapsedTime;
  final double? groundHeight;

  final SkyPainter skyPainter;
  final MemoryPainter memoryPainter;

  TreeStructureInfo? _treeStructure;

  TreePainter({
    required this.tree,
    required this.memories,
    required this.animation,
    required this.elapsedTime,
    this.groundHeight = 0.80,
  }) : skyPainter = SkyPainter(elapsedTime: elapsedTime),
       memoryPainter = MemoryPainter(
         elapsedTime: elapsedTime,
         tree: tree,
         memories: memories,
       ),
       super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * groundHeight!;

    // 1. Paint sky
    skyPainter.paint(canvas, size);

    // 2. Capture tree structure before painting
    _treeStructure = _captureTreeStructure(size, centerX, groundY);

    // 3. Paint tree with zoom
    canvas.save();
    canvas.translate(centerX, groundY);
    canvas.scale(1.5, 1.5);
    canvas.translate(-centerX, -groundY);

    _paintTree(canvas, size, centerX, groundY);

    canvas.restore();

    // 4. Paint memories with tree structure info
    if (tree.isPlanted) {
      memoryPainter.paint(
        canvas,
        size,
        centerX,
        groundY,
        treeStructure: _treeStructure,
      );
    }
  }

  void _paintTree(Canvas canvas, Size size, double centerX, double groundY) {
    switch (tree.stage) {
      case TreeStage.notPlanted:
        final painter = UnplantedPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.seedling:
        final painter = SeedlingPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.sprouting:
        final painter = SproutingPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.growing:
        final painter = GrowingPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.flourishing:
        final painter = FlourishingPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.blooming:
        final painter = BloomingPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.radiant:
        final painter = RadiantPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.mature:
        final painter = MaturePainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;

      case TreeStage.completed:
        final painter = CompletedPainter(
          elapsedTime: elapsedTime,
          tree: tree,
        );
        painter.paint(canvas, size, centerX, groundY);
        break;
    }
  }

  TreeStructureInfo _captureTreeStructure(
    Size size,
    double centerX,
    double groundY,
  ) {
    final schema = BranchSchemas.getSchema(tree.stage);
    final trunkHeight = tree.height * schema.heightMultiplier;
    final trunkWidth =
        BranchSchemas.baseTrunkWidth * schema.trunkWidthMultiplier;

    final List<BranchInfo> branches = [];

    // Build branch info from schema
    for (final branchConfig in schema.branches) {
      final y = groundY - trunkHeight * branchConfig.heightRatio;
      final startPoint = Offset(centerX, y);
      final endPoint = Offset(
        centerX +
            branchConfig.length *
                math.sin(branchConfig.angle) *
                1.5, // Apply zoom
        y - branchConfig.length * math.cos(branchConfig.angle) * 1.5,
      );

      branches.add(
        BranchInfo(
          startPoint: startPoint,
          endPoint: endPoint,
          angle: branchConfig.angle,
          length: branchConfig.length * 1.5,
        ),
      );
    }

    return TreeStructureInfo(
      stage: tree.stage,
      trunkHeight: trunkHeight,
      trunkWidth: trunkWidth,
      branches: branches,
      treeBase: Offset(centerX, groundY),
    );
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}
