import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Grateful Emotion - Twinkling stars in the sky
class GratefulPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final y = 40.0 + (index % 3) * 30;
    _drawStar(ctx.canvas, Offset(x, y), ctx.elapsedTime, index);
  }

  void _drawStar(Canvas canvas, Offset position, double time, int index) {
    const iconSize = 15.0;
    final twinkle = (math.sin(time * math.pi * 4 + index * 2) + 1) / 2;
    final scale = 0.7 + twinkle * 0.6;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);

    final paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.8 + twinkle * 0.2)
      ..style = PaintingStyle.fill;

    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * math.pi * 2 / 5) - math.pi / 2;
      final outerRadius = iconSize * 0.5;
      final innerRadius = iconSize * 0.2;

      if (i == 0) {
        starPath.moveTo(
          math.cos(angle) * outerRadius,
          math.sin(angle) * outerRadius,
        );
      } else {
        starPath.lineTo(
          math.cos(angle) * outerRadius,
          math.sin(angle) * outerRadius,
        );
      }

      final innerAngle = angle + (math.pi / 5);
      starPath.lineTo(
        math.cos(innerAngle) * innerRadius,
        math.sin(innerAngle) * innerRadius,
      );
    }
    starPath.close();
    canvas.drawPath(starPath, paint);

    // Glow
    paint
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3 * twinkle)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(starPath, paint);

    canvas.restore();
  }
}
