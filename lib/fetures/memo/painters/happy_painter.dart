import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Happy Emotion - Beautiful flowers on branches
class HappyPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final random = math.Random(memory.id.hashCode);

    // Position on branch
    Offset position;
    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      final branches = ctx.treeStructure!.branches;
      final branchIndex = index % branches.length;
      final branch = branches[branchIndex];

      final t = 0.7 + random.nextDouble() * 0.3;
      final x =
          branch.startPoint.dx +
          (branch.endPoint.dx - branch.startPoint.dx) * t;
      final y =
          branch.startPoint.dy +
          (branch.endPoint.dy - branch.startPoint.dy) * t;

      final sway = math.sin(ctx.elapsedTime * 2 + index) * 3;
      position = Offset(x + sway, y);
    } else {
      // Fallback
      final angle = (index / total) * math.pi * 2;
      final radius = ctx.trunkHeight * 0.2;
      final x = ctx.centerX + math.cos(angle) * radius;
      final y = ctx.groundY - ctx.trunkHeight * 0.7;
      final sway = math.sin(ctx.elapsedTime * 2 + index) * 2;
      position = Offset(x + sway, y);
    }

    _drawFlower(ctx.canvas, position, ctx.elapsedTime, index);
  }

  void _drawFlower(Canvas canvas, Offset position, double time, int index) {
    const iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    // Gentle breathing animation
    final scale = 1.0 + math.sin(time * math.pi * 2 + index) * 0.1;
    canvas.scale(scale);

    // Draw 5 elegant petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i * math.pi * 2 / 5));

      // Gradient petals
      paint.shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFFFF),
              const Color(0xFFFFE4E1),
              const Color(0xFFFFB6C1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              -iconSize * 0.4,
              -iconSize * 0.8,
              iconSize * 0.8,
              iconSize * 0.8,
            ),
          );

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          iconSize * 0.2,
          -iconSize * 0.25,
          0,
          -iconSize * 0.45,
        )
        ..quadraticBezierTo(-iconSize * 0.2, -iconSize * 0.25, 0, 0);

      canvas.drawPath(petalPath, paint);
      canvas.restore();
    }

    paint.shader = null;

    // Golden center with detail
    paint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, iconSize * 0.15, paint);

    paint.color = const Color(0xFFFFA500);
    canvas.drawCircle(Offset.zero, iconSize * 0.08, paint);

    // Pollen dots
    paint.color = const Color(0xFFFF8C00).withValues(alpha: 0.6);
    for (int i = 0; i < 6; i++) {
      final dotAngle = (i * math.pi * 2 / 6);
      final dotPos = Offset(
        math.cos(dotAngle) * iconSize * 0.08,
        math.sin(dotAngle) * iconSize * 0.08,
      );
      canvas.drawCircle(dotPos, iconSize * 0.04, paint);
    }

    canvas.restore();
  }
}
