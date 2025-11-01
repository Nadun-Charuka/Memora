import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';

import 'base_stage_painter.dart';

/// Blooming Stage (28-38 memories)
/// Elegant tree with beautiful flowers
class BloomingPainter extends BaseTreeStagePainter {
  BloomingPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.blooming;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Elegant, refined trunk
    final trunkPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF5D4037),
              const Color(0xFF8D6E63),
              const Color(0xFF6D4C41),
              const Color(0xFF5D4037),
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    final path = Path()
      ..moveTo(centerX - width * 0.75, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.55,
        groundY - height * 0.15,
        centerX - width * 0.45,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.3 + sway * 0.8,
        groundY - height * 0.7,
        centerX - width * 0.25 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.25 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.3 + sway * 0.8,
        groundY - height * 0.7,
        centerX + width * 0.45,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX + width * 0.55,
        groundY - height * 0.15,
        centerX + width * 0.75,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Refined bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 18) {
      final curve = math.sin(i * 0.25) * 2;
      canvas.drawLine(
        Offset(centerX - width * 0.2 + curve, groundY - i),
        Offset(centerX + width * 0.15 + curve, groundY - i - 8),
        barkPaint,
      );
    }
  }

  @override
  void drawLeafCluster(
    Canvas canvas,
    Offset center,
    BranchConfig config,
  ) {
    final random = math.Random(center.dx.toInt());

    for (int i = 0; i < config.leafCount; i++) {
      final angle = config.angle + (random.nextDouble() - 0.5) * 2.8;
      final distance = 8 + random.nextDouble() * 28;
      final sway = math.sin(elapsedTime * math.pi + i * 0.5) * 1.5;

      final position = Offset(
        center.dx + math.cos(angle) * distance + sway,
        center.dy + math.sin(angle) * distance,
      );

      // Mix of flowers and leaves
      if (i % 3 == 0) {
        final bloom = 0.85 + (math.sin(elapsedTime * math.pi * 2 + i) * 0.15);
        _drawFlower(canvas, position, bloom);
      } else {
        final leafSize = config.leafSize + random.nextDouble() * 3;
        drawSingleLeaf(canvas, position, leafSize, angle, false);
      }
    }
  }

  void _drawFlower(Canvas canvas, Offset center, double bloom) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final petalPaint = Paint()..style = PaintingStyle.fill;

    // Draw 5 elegant petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i * math.pi * 2 / 5));

      petalPaint.shader =
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
            Rect.fromLTWH(-6 * bloom, -12 * bloom, 12 * bloom, 12 * bloom),
          );

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          3.5 * bloom,
          -5 * bloom,
          2 * bloom,
          -10 * bloom,
        )
        ..quadraticBezierTo(
          0,
          -8 * bloom,
          -2 * bloom,
          -10 * bloom,
        )
        ..quadraticBezierTo(-3.5 * bloom, -5 * bloom, 0, 0);
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Golden center
    final centerPaint = Paint()..style = PaintingStyle.fill;

    centerPaint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 3.5 * bloom, centerPaint);

    centerPaint.color = const Color(0xFFFFA500);
    canvas.drawCircle(Offset.zero, 2 * bloom, centerPaint);

    // Pollen dots
    centerPaint.color = const Color(0xFFFF8C00).withValues(alpha: 0.6);
    for (int i = 0; i < 6; i++) {
      final dotAngle = (i * math.pi * 2 / 6);
      final dotPos = Offset(
        math.cos(dotAngle) * 2 * bloom,
        math.sin(dotAngle) * 2 * bloom,
      );
      canvas.drawCircle(dotPos, 0.6 * bloom, centerPaint);
    }

    canvas.restore();
  }

  @override
  List<Color> getLeafColors() {
    return const [
      Color(0xFF9CCC65),
      Color(0xFF7CB342),
      Color(0xFF689F38),
    ];
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Falling petals
    _drawFallingPetals(canvas, centerX, groundY, trunkHeight);
  }

  void _drawFallingPetals(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final petalPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final progress = (elapsedTime * 0.2 + i * 0.2) % 1.0;
      final x =
          centerX + (i % 3 - 1) * 40 + math.sin(progress * math.pi * 4) * 20;
      final y = groundY - height * 0.8 + (progress * height * 0.9);
      final rotation = progress * math.pi * 4;
      final opacity = math.sin(progress * math.pi) * 0.6;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      petalPaint.color = const Color(0xFFFFB6C1).withValues(alpha: opacity);

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(2, -3, 1, -6)
        ..quadraticBezierTo(0, -5, -1, -6)
        ..quadraticBezierTo(-2, -3, 0, 0);

      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }
  }
}
