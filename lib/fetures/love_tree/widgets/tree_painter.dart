// FILE: lib/tree_painter.dart (REPLACE the old code with this)

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

  // Our specialist artist instances
  final SkyPainter skyPainter;
  final MemoryPainter memoryPainter;
  final Map<TreeStage, TreeStagePainter> treePainters;

  TreePainter({
    required this.tree,
    required this.memories,
    required this.animation,
  }) : skyPainter = SkyPainter(animation: animation),
       memoryPainter = MemoryPainter(
         animation: animation,
         tree: tree,
         memories: memories,
       ),
       treePainters = {
         TreeStage.notPlanted: UnplantedPainter(
           animation: animation,
           tree: tree,
         ),
         TreeStage.seedling: SeedlingPainter(
           animation: animation,
           tree: tree,
         ),
         TreeStage.growing: GrowingPainter(
           animation: animation,
           tree: tree,
         ),
         TreeStage.blooming: BloomingPainter(
           animation: animation,
           tree: tree,
         ),
         TreeStage.mature: MaturePainter(
           animation: animation,
           tree: tree,
         ),
         TreeStage.completed: MaturePainter(
           animation: animation,
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
    // A simpler repaint condition can often be just checking the animation
    return true;
  }
}
