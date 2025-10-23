// FILE: lib/tree_painter.dart

import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';

import 'painters/memory_painter.dart';
import 'painters/sky_painter.dart';
import 'painters/tree_stage_painters.dart';

class TreePainter extends CustomPainter {
  final LoveTree tree;
  final List<Memory> memories;
  final Animation<double> animation; // Keep for repaint notification
  final double elapsedTime; // NEW: Continuous time

  // Our specialist artist instances
  final SkyPainter skyPainter;
  final MemoryPainter memoryPainter;
  final Map<TreeStage, TreeStagePainter> treePainters;

  TreePainter({
    required this.tree,
    required this.memories,
    required this.animation,
    required this.elapsedTime, // NEW
  }) : skyPainter = SkyPainter(elapsedTime: elapsedTime), // CHANGED
       memoryPainter = MemoryPainter(
         elapsedTime: elapsedTime, // CHANGED
         tree: tree,
         memories: memories,
       ),
       treePainters = {
         TreeStage.notPlanted: UnplantedPainter(
           elapsedTime: elapsedTime, // CHANGED
           tree: tree,
         ),
         TreeStage.seedling: SeedlingPainter(
           elapsedTime: elapsedTime, // CHANGED
           tree: tree,
         ),
         TreeStage.growing: GrowingPainter(
           elapsedTime: elapsedTime, // CHANGED
           tree: tree,
         ),
         TreeStage.blooming: BloomingPainter(
           elapsedTime: elapsedTime, // CHANGED
           tree: tree,
         ),
         TreeStage.mature: MaturePainter(
           elapsedTime: elapsedTime, // CHANGED
           tree: tree,
         ),
         TreeStage.completed: CompletedPainter(
           elapsedTime: elapsedTime, // CHANGED
           tree: tree,
         ),
       },
       super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.80;

    // 1. Delegate sky painting
    skyPainter.paint(canvas, size);

    // This part handles the main zoom transform
    canvas.save();
    canvas.translate(centerX, groundY);
    canvas.scale(1.5, 1.5);
    canvas.translate(-centerX, -groundY);

    // 2. Select the correct tree painter and delegate tree and ground painting
    final currentTreePainter = treePainters[tree.stage];
    currentTreePainter?.paint(canvas, size, centerX, groundY);

    canvas.restore();

    // 3. Delegate memory painting (outside the zoom transform)
    if (tree.isPlanted) {
      memoryPainter.paint(canvas, size, centerX, groundY);
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}
