import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Sad Emotion - Falling raindrops
class SadPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final fallSpeed = 0.5 + (index * 0.15);
    final progress = (ctx.elapsedTime * fallSpeed) % 1.0;

    final startY = ctx.size.height * 0.1;
    final endY = ctx.size.height * 0.85;
    final y = startY + ((endY - startY) * progress);

    final drift = math.sin(progress * math.pi * 3) * 10;
    _drawRaindrop(ctx.canvas, Offset(x + drift, y), progress);
  }

  void _drawRaindrop(Canvas canvas, Offset position, double progress) {
    const iconSize = 8.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final opacity = 0.5 + (progress * 0.4);
    paint.color = const Color(0xFF4682B4).withValues(alpha: opacity);

    // Teardrop shape
    final dropPath = Path()
      ..moveTo(0, -iconSize)
      ..quadraticBezierTo(
        iconSize * 0.5,
        -iconSize * 0.3,
        iconSize * 0.3,
        iconSize * 0.3,
      )
      ..quadraticBezierTo(0, iconSize * 0.6, 0, iconSize * 0.7)
      ..quadraticBezierTo(0, iconSize * 0.6, -iconSize * 0.3, iconSize * 0.3)
      ..quadraticBezierTo(-iconSize * 0.5, -iconSize * 0.3, 0, -iconSize);

    canvas.drawPath(dropPath, paint);

    // Highlight
    paint.color = Colors.white.withValues(alpha: 0.5 * opacity);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.4),
      iconSize * 0.18,
      paint,
    );

    // Splash effect when near ground
    if (progress > 0.92) {
      final splashProgress = (progress - 0.92) / 0.08;
      final splashSize = splashProgress * iconSize * 1.5;
      paint.color = const Color(0xFF4682B4).withValues(
        alpha: 0.4 * (1 - splashProgress),
      );

      for (int i = 0; i < 4; i++) {
        final angle = (i / 4) * math.pi * 2;
        final splashOffset = Offset(
          math.cos(angle) * splashSize,
          iconSize * 0.7 + math.sin(angle) * splashSize * 0.3,
        );
        canvas.drawCircle(splashOffset, splashSize * 0.3, paint);
      }
    }

    canvas.restore();
  }
}
