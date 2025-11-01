import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Awful Emotion - Storm clouds with lightning
class AwfulPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final random = math.Random(memory.id.hashCode);
    final cloudScale = 0.4 + random.nextDouble() * 0.4;
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final y = 70.0 + random.nextDouble() * 50.0;

    _drawStormCloud(
      ctx.canvas,
      Offset(x, y),
      ctx.elapsedTime,
      cloudScale,
      random,
      index,
    );
  }

  void _drawStormCloud(
    Canvas canvas,
    Offset position,
    double time,
    double cloudScale,
    math.Random random,
    int index,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;
    final lightningFlash = (time * 2 + random.nextDouble() * 3.0 + index) % 3.0;
    final isLightning = lightningFlash < 0.2;
    final drift = isLightning
        ? math.sin(time * math.pi * 40) * 3
        : math.sin(time * 0.5 + index) * 50;

    canvas.save();
    canvas.translate(position.dx + drift, position.dy);

    // Shadow beneath cloud
    final shadowPaint = Paint()
      ..color = const Color(0xFF2D3748).withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * cloudScale);
    canvas.drawCircle(Offset.zero, 40 * cloudScale, shadowPaint);

    // Cloud body (dark gray)
    canvas.scale(cloudScale);
    paint.color = const Color(0xFF4A5568).withValues(alpha: 0.8);

    // Multiple cloud puffs
    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);
    canvas.drawCircle(const Offset(32, -3), 23, paint);
    canvas.drawCircle(const Offset(45, 2), 19, paint);
    canvas.drawCircle(const Offset(20, 6), 20, paint);
    canvas.drawCircle(const Offset(28, 8), 17, paint);

    // Darker overlay for storm effect
    paint.color = const Color(0xFF2D3748).withValues(alpha: 0.4);
    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);

    canvas.scale(1.0 / cloudScale);

    // Lightning bolt
    if (isLightning) {
      final boltPaint = Paint()
        ..color = const Color(0xFFFFFACD).withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final lightningPath = Path()
        ..moveTo(15, 8)
        ..lineTo(20, 25)
        ..lineTo(15, 25)
        ..lineTo(22, 45)
        ..lineTo(17, 45)
        ..lineTo(25, 65);

      canvas.drawPath(lightningPath, boltPaint);

      // Lightning glow
      boltPaint
        ..color = const Color(0xFFFFFF00).withValues(alpha: 0.4)
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(lightningPath, boltPaint);

      // Flash effect on cloud
      canvas.scale(cloudScale);
      paint
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.2)
        ..maskFilter = null;
      canvas.drawCircle(const Offset(15, -8), 26, paint);
      canvas.drawCircle(const Offset(32, -3), 23, paint);
      canvas.scale(1.0 / cloudScale);
    }
    canvas.restore();
  }
}
