// ============================================================================
// ENHANCED TREE PAINTER - Captures tree structure for memory positioning
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'painters/memory_painter.dart';
import 'painters/sky_painter.dart';
import 'painters/tree_stage_painters.dart';

class TreePainter extends CustomPainter {
  final LoveTree tree;
  final List<Memory> memories;
  final Animation<double> animation;
  final double elapsedTime;
  final double? groundHeight;

  final SkyPainter skyPainter;
  final MemoryPainter memoryPainter;
  final Map<TreeStage, TreeStagePainter> treePainters;

  // NEW: Store captured tree structure
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
       treePainters = {
         TreeStage.notPlanted: UnplantedPainter(
           elapsedTime: elapsedTime,
           tree: tree,
         ),
         TreeStage.seedling: SeedlingPainter(
           elapsedTime: elapsedTime,
           tree: tree,
         ),
         TreeStage.growing: GrowingPainter(
           elapsedTime: elapsedTime,
           tree: tree,
         ),
         TreeStage.blooming: BloomingPainter(
           elapsedTime: elapsedTime,
           tree: tree,
         ),
         TreeStage.mature: MaturePainter(
           elapsedTime: elapsedTime,
           tree: tree,
         ),
         TreeStage.completed: CompletedPainter(
           elapsedTime: elapsedTime,
           tree: tree,
         ),
       },
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

    final currentTreePainter = treePainters[tree.stage];
    currentTreePainter?.paint(canvas, size, centerX, groundY);

    canvas.restore();

    // 4. Paint memories with tree structure info
    if (tree.isPlanted) {
      memoryPainter.paint(
        canvas,
        size,
        centerX,
        groundY,
        treeStructure: _treeStructure, // Pass structure!
      );
    }
  }

  // ✨ NEW: Capture tree structure based on current stage
  TreeStructureInfo _captureTreeStructure(
    Size size,
    double centerX,
    double groundY,
  ) {
    final trunkHeight =
        tree.height *
        (tree.stage == TreeStage.seedling
            ? 2.0
            : tree.stage == TreeStage.growing
            ? 1.5
            : tree.stage == TreeStage.blooming
            ? 1.2
            : 1.0);

    final List<BranchInfo> branches = [];

    // Define branches based on stage
    switch (tree.stage) {
      case TreeStage.notPlanted:
        // No branches
        break;

      case TreeStage.seedling:
        // Young leaves positions (not really branches yet)
        final stemHeight = trunkHeight;
        branches.addAll([
          BranchInfo(
            startPoint: Offset(centerX, groundY - stemHeight * 0.5),
            endPoint: Offset(centerX - 8, groundY - stemHeight * 0.5),
            angle: -0.7,
            length: 8,
          ),
          BranchInfo(
            startPoint: Offset(centerX, groundY - stemHeight * 0.7),
            endPoint: Offset(centerX + 8, groundY - stemHeight * 0.7),
            angle: 0.7,
            length: 8,
          ),
        ]);
        break;

      case TreeStage.growing:
        // Wild asymmetric branches
        final branchData = [
          {'y': 0.3, 'length': 55.0, 'angle': -1.1},
          {'y': 0.33, 'length': 48.0, 'angle': 0.85},
          {'y': 0.48, 'length': 52.0, 'angle': -0.9},
          {'y': 0.51, 'length': 58.0, 'angle': 0.75},
          {'y': 0.62, 'length': 45.0, 'angle': -0.7},
          {'y': 0.65, 'length': 50.0, 'angle': 0.8},
          {'y': 0.75, 'length': 42.0, 'angle': -0.55},
          {'y': 0.78, 'length': 38.0, 'angle': 0.6},
        ];

        for (var data in branchData) {
          final y = groundY - trunkHeight * (data['y'] as double);
          final length = (data['length'] as double) * 1.5; // Apply zoom
          final angle = data['angle'] as double;

          final startPoint = Offset(centerX, y);
          final endPoint = Offset(
            centerX + length * math.sin(angle),
            y - length * math.cos(angle),
          );

          branches.add(
            BranchInfo(
              startPoint: startPoint,
              endPoint: endPoint,
              angle: angle,
              length: length,
            ),
          );
        }
        break;

      case TreeStage.blooming:
        // Elegant symmetric branches
        final branchData = [
          {'y': 0.22, 'length': 75.0, 'angle': -1.1},
          {'y': 0.25, 'length': 75.0, 'angle': 1.1},
          {'y': 0.38, 'length': 70.0, 'angle': -0.95},
          {'y': 0.41, 'length': 70.0, 'angle': 0.95},
          {'y': 0.52, 'length': 65.0, 'angle': -0.85},
          {'y': 0.55, 'length': 65.0, 'angle': 0.85},
          {'y': 0.66, 'length': 58.0, 'angle': -0.75},
          {'y': 0.69, 'length': 58.0, 'angle': 0.75},
        ];

        for (var data in branchData) {
          final y = groundY - trunkHeight * (data['y'] as double);
          final length = (data['length'] as double) * 1.5;
          final angle = data['angle'] as double;

          final startPoint = Offset(centerX, y);
          final endPoint = Offset(
            centerX + length * math.sin(angle),
            y - length * math.cos(angle),
          );

          branches.add(
            BranchInfo(
              startPoint: startPoint,
              endPoint: endPoint,
              angle: angle,
              length: length,
            ),
          );
        }
        break;

      case TreeStage.mature:
      case TreeStage.completed:
        // Full mature branches
        final branchData = [
          {'y': 0.2, 'length': 80.0, 'angle': -1.0},
          {'y': 0.22, 'length': 80.0, 'angle': 1.0},
          {'y': 0.4, 'length': 75.0, 'angle': -0.8},
          {'y': 0.42, 'length': 75.0, 'angle': 0.8},
          {'y': 0.6, 'length': 65.0, 'angle': -0.7},
          {'y': 0.62, 'length': 65.0, 'angle': 0.7},
          {'y': 0.78, 'length': 50.0, 'angle': -0.6},
          {'y': 0.8, 'length': 50.0, 'angle': 0.6},
        ];

        for (var data in branchData) {
          final y = groundY - trunkHeight * (data['y'] as double);
          final length = (data['length'] as double) * 1.5;
          final angle = data['angle'] as double;

          final startPoint = Offset(centerX, y);
          final endPoint = Offset(
            centerX + length * math.sin(angle),
            y - length * math.cos(angle),
          );

          branches.add(
            BranchInfo(
              startPoint: startPoint,
              endPoint: endPoint,
              angle: angle,
              length: length,
            ),
          );
        }
        break;
    }

    return TreeStructureInfo(
      stage: tree.stage,
      trunkHeight: trunkHeight,
      trunkWidth: tree.stage == TreeStage.seedling ? 4.0 : 18.0,
      branches: branches,
    );
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}
