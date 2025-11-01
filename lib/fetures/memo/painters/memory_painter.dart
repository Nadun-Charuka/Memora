import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/model/tree_structure.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';
import 'happy_painter.dart';
import 'excited_painter.dart';
import 'joyful_painter.dart';
import 'grateful_painter.dart';
import 'love_painter.dart';
import 'sad_painter.dart';
import 'nostalgic_painter.dart';
import 'peaceful_painter.dart';
import 'awful_painter.dart';

/// Main memory painter that delegates to emotion-specific painters
class MemoryPainter {
  final double elapsedTime;
  final LoveTree tree;
  final List<Memory> memories;
  late final Map<MemoryEmotion, BaseEmotionPainter> _painters;

  MemoryPainter({
    required this.elapsedTime,
    required this.tree,
    required this.memories,
  }) {
    _painters = {
      MemoryEmotion.happy: HappyPainter(),
      MemoryEmotion.excited: ExcitedPainter(),
      MemoryEmotion.joyful: JoyfulPainter(),
      MemoryEmotion.grateful: GratefulPainter(),
      MemoryEmotion.love: LovePainter(),
      MemoryEmotion.sad: SadPainter(),
      MemoryEmotion.nostalgic: NostalgicPainter(),
      MemoryEmotion.peaceful: PeacefulPainter(),
      MemoryEmotion.awful: AwfulPainter(),
    };
  }

  void paint(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY, {
    TreeStructureInfo? treeStructure,
  }) {
    if (memories.isEmpty) return;

    final context = AnimationContext(
      canvas: canvas,
      size: size,
      centerX: centerX,
      groundY: groundY,
      elapsedTime: elapsedTime,
      tree: tree,
      treeStructure: treeStructure,
    );

    // Group memories by emotion
    final groupedMemories = <MemoryEmotion, List<Memory>>{};
    for (var emotion in MemoryEmotion.values) {
      groupedMemories[emotion] = memories
          .where((m) => m.emotion == emotion)
          .toList();
    }

    // Paint each emotion group
    for (var entry in groupedMemories.entries) {
      if (entry.value.isEmpty) continue;
      final painter = _painters[entry.key];
      if (painter != null) {
        painter.paintAll(context, entry.value);
      }
    }
  }
}
