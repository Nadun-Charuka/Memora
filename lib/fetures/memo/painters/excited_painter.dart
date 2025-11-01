import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Excited Emotion - Flying birds with proper wings
class ExcitedPainter extends BaseEmotionPainter {
  static final _colorPalettes = [
    [
      Color(0xFF4A90E2),
      Color(0xFF87CEEB),
      Color(0xFF4A90E2),
      Color(0xFFF5A623),
    ],
    [
      Color(0xFFD0021B),
      Color(0xFFFF6347),
      Color(0xFFD0021B),
      Color(0xFFE27A3F),
    ],
    [
      Color(0xFF417505),
      Color(0xFF7ED321),
      Color(0xFF417505),
      Color(0xFFB8E986),
    ],
    [
      Color(0xFF9013FE),
      Color(0xFFBD10E0),
      Color(0xFF9013FE),
      Color(0xFFFFD700),
    ],
    [
      Color(0xFFF5A623),
      Color(0xFFF8E71C),
      Color(0xFFF5A623),
      Color(0xFFE27A3F),
    ],
  ];

  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final palette = _colorPalettes[index % _colorPalettes.length];
    final isFlyingRight = index % 2 == 0;

    final birdSpeed = 0.3 + (index * 0.2);
    final progress = (ctx.elapsedTime * birdSpeed + (index / total)) % 1.0;

    final x = isFlyingRight
        ? ctx.size.width * progress
        : ctx.size.width * (1.0 - progress);

    final pathVariation = (index % 3) * 2.0;
    final y =
        60.0 +
        (index * 35) +
        math.sin(progress * math.pi * 4 + pathVariation) * 20 +
        math.sin(ctx.elapsedTime * math.pi * 2 + index) * 8;

    _drawBird(
      ctx.canvas,
      Offset(x, y),
      ctx.elapsedTime,
      index,
      palette,
      isFlyingRight,
    );
  }

  void _drawBird(
    Canvas canvas,
    Offset position,
    double time,
    int index,
    List<Color> palette,
    bool facingRight,
  ) {
    const baseSize = 18.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final tilt = math.sin(time * math.pi * 2 + index) * 0.1;
    canvas.rotate(tilt);
    if (!facingRight) canvas.scale(-1.0, 1.0);

    // Wing flap animation
    final wingFlap = math.sin(time * math.pi * 12 + index * 0.5) * 0.6;
    final bodyScale = 1.0 + wingFlap.abs() * 0.08;
    canvas.scale(bodyScale, 1.0);

    // Body
    paint.shader =
        LinearGradient(
          colors: [palette[0], palette[1]],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(
            -baseSize * 0.5,
            -baseSize * 0.25,
            baseSize,
            baseSize * 0.5,
          ),
        );

    final bodyPath = Path()
      ..moveTo(-baseSize * 0.3, 0)
      ..quadraticBezierTo(
        -baseSize * 0.45,
        -baseSize * 0.25,
        -baseSize * 0.5,
        -baseSize * 0.1,
      )
      ..quadraticBezierTo(
        -baseSize * 0.55,
        baseSize * 0.2,
        -baseSize * 0.3,
        baseSize * 0.25,
      )
      ..quadraticBezierTo(baseSize * 0.2, baseSize * 0.25, baseSize * 0.4, 0)
      ..quadraticBezierTo(baseSize * 0.2, -baseSize * 0.25, -baseSize * 0.3, 0)
      ..close();

    canvas.drawPath(bodyPath, paint);
    paint.shader = null;

    // Head
    paint.color = palette[1];
    canvas.drawCircle(
      Offset(baseSize * 0.35, -baseSize * 0.05),
      baseSize * 0.2,
      paint,
    );

    // Eye
    paint.color = Colors.black.withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(baseSize * 0.45, -baseSize * 0.1),
      baseSize * 0.04,
      paint,
    );

    // Beak
    paint.color = palette[3];
    final beakPath = Path()
      ..moveTo(baseSize * 0.48, -baseSize * 0.05)
      ..lineTo(baseSize * 0.65, 0)
      ..lineTo(baseSize * 0.48, baseSize * 0.05)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Wings
    canvas.scale(1.0 / bodyScale, 1.0);
    paint.color = palette[2];

    final wingBaseAngle = -0.6;

    // Top wing
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05);
    canvas.rotate(wingBaseAngle + wingFlap);
    _drawWing(canvas, baseSize, paint);
    canvas.restore();

    // Bottom wing
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05);
    canvas.rotate(-(wingBaseAngle + wingFlap));
    canvas.scale(1, -1);
    _drawWing(canvas, baseSize, paint);
    canvas.restore();

    canvas.scale(bodyScale, 1.0);

    // Tail
    paint.color = palette[0].withValues(alpha: 0.9);
    final tailPath = Path()
      ..moveTo(-baseSize * 0.45, 0)
      ..lineTo(-baseSize * 0.65, -baseSize * 0.1)
      ..lineTo(-baseSize * 0.55, 0)
      ..lineTo(-baseSize * 0.65, baseSize * 0.1)
      ..close();
    canvas.drawPath(tailPath, paint);

    canvas.restore();
  }

  void _drawWing(Canvas canvas, double baseSize, Paint paint) {
    final wingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        baseSize * 0.3,
        -baseSize * 0.4,
        baseSize * 0.8,
        -baseSize * 0.3,
      )
      ..quadraticBezierTo(baseSize * 0.5, -baseSize * 0.1, baseSize * 0.4, 0)
      ..close();
    canvas.drawPath(wingPath, paint);

    // Wing detail
    paint.color = Colors.black.withValues(alpha: 0.2);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(baseSize * 0.2, -baseSize * 0.05),
      Offset(baseSize * 0.6, -baseSize * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(baseSize * 0.15, 0),
      Offset(baseSize * 0.5, -baseSize * 0.15),
      paint,
    );
    paint.style = PaintingStyle.fill;
  }
}
