import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Joyful Emotion - Hanging fruits on branches
class JoyfulPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    Offset position;

    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      final branches = ctx.treeStructure!.branches;
      final branchIndex = index % branches.length;
      final branch = branches[branchIndex];

      final x = branch.endPoint.dx;
      final y = branch.endPoint.dy + 15;

      final swing = math.sin(ctx.elapsedTime * math.pi * 2 + index) * 3;
      position = Offset(x + swing, y);
    } else {
      final angle = (index / total) * math.pi * 2;
      final radius = ctx.trunkHeight * 0.15;
      final x = ctx.centerX + math.cos(angle) * radius;
      final y = ctx.groundY - ctx.trunkHeight * 0.8;
      final swing = math.sin(ctx.elapsedTime * math.pi * 2 + index) * 2;
      position = Offset(x + swing, y);
    }

    _drawFruit(ctx.canvas, position);
  }

  void _drawFruit(Canvas canvas, Offset position) {
    const iconSize = 15.0;
    canvas.save();
    canvas.translate(position.dx, position.dy);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -iconSize * 0.5),
      Offset(0, -iconSize * 0.8),
      stemPaint,
    );

    // Fruit body with gradient
    final fruitPaint = Paint()..style = PaintingStyle.fill;

    fruitPaint.shader =
        RadialGradient(
          colors: [
            const Color(0xFFFF6347),
            const Color(0xFFFF4500),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset.zero, radius: iconSize * 0.45),
        );

    canvas.drawCircle(Offset.zero, iconSize * 0.45, fruitPaint);

    // Highlight
    fruitPaint.shader = null;
    fruitPaint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.15),
      iconSize * 0.15,
      fruitPaint,
    );

    // Leaf
    final leafPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.fill;

    final leafPath = Path()
      ..moveTo(iconSize * 0.1, -iconSize * 0.6)
      ..quadraticBezierTo(
        iconSize * 0.25,
        -iconSize * 0.65,
        iconSize * 0.3,
        -iconSize * 0.6,
      )
      ..quadraticBezierTo(
        iconSize * 0.25,
        -iconSize * 0.55,
        iconSize * 0.1,
        -iconSize * 0.5,
      )
      ..close();

    canvas.drawPath(leafPath, leafPaint);

    canvas.restore();
  }
}
