import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';
import 'base_stage_painter.dart';

/// Radiant Stage (38-48 memories)
/// Peak beauty with golden highlights and magical glow
class RadiantPainter extends BaseTreeStagePainter {
  RadiantPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.radiant;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Majestic trunk with subtle golden highlights
    final trunkPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF4A3428),
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
      ..moveTo(centerX - width * 0.85, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.65,
        groundY - height * 0.15,
        centerX - width * 0.5,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.35 + sway * 0.8,
        groundY - height * 0.7,
        centerX - width * 0.28 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.28 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.35 + sway * 0.8,
        groundY - height * 0.7,
        centerX + width * 0.5,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX + width * 0.65,
        groundY - height * 0.15,
        centerX + width * 0.85,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Detailed bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 18) {
      final curve = math.sin(i * 0.2) * 3;
      canvas.drawLine(
        Offset(centerX - width * 0.25 + curve, groundY - i),
        Offset(centerX + width * 0.2 + curve, groundY - i - 8),
        barkPaint,
      );
    }

    // Golden highlights on trunk
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 45) {
      canvas.drawLine(
        Offset(centerX - width * 0.2, groundY - i - 10),
        Offset(centerX + width * 0.15, groundY - i - 16),
        highlightPaint,
      );
    }
  }

  @override
  void paintBackgroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    super.paintBackgroundEffects(canvas, centerX, groundY, trunkHeight);

    // Enhanced radiant glow with pulse
    final glowPulse = (math.sin(elapsedTime * math.pi * 2) + 1) / 2;

    // Outer golden aura
    final outerGlow = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.08 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(
      Offset(centerX, groundY - trunkHeight * 0.5),
      150,
      outerGlow,
    );

    // Inner bright core
    final innerGlow = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.12 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(
      Offset(centerX, groundY - trunkHeight * 0.5),
      100,
      innerGlow,
    );
  }

  @override
  void drawLeafCluster(
    Canvas canvas,
    Offset center,
    BranchConfig config,
  ) {
    final random = math.Random(center.dx.toInt());

    for (int i = 0; i < config.leafCount; i++) {
      final angle = config.angle + (random.nextDouble() - 0.5) * 2.5;
      final distance = 8 + random.nextDouble() * 25;
      final rustleX = math.sin(elapsedTime * math.pi * 2 + i * 0.7) * 2.5;
      final rustleY = math.cos(elapsedTime * math.pi * 1.5 + i * 0.5) * 1.5;

      final leafPos = Offset(
        center.dx + math.cos(angle) * distance + rustleX,
        center.dy + math.sin(angle) * distance + rustleY,
      );

      // More golden leaves
      final isGolden = i % 4 == 0;
      final leafSize = config.leafSize + random.nextDouble() * 4;

      if (i % 5 == 0) {
        // Some flowers still present
        final bloom = 0.9 + math.sin(elapsedTime * math.pi + i) * 0.1;
        _drawRadiantFlower(canvas, leafPos, bloom);
      } else {
        drawSingleLeaf(canvas, leafPos, leafSize, angle, isGolden);
      }
    }
  }

  void _drawRadiantFlower(Canvas canvas, Offset center, double bloom) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Glow around flower
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, 8 * bloom, glowPaint);

    final petalPaint = Paint()..style = PaintingStyle.fill;

    // Golden-tinted petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i * math.pi * 2 / 5));

      petalPaint.shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF8DC),
              const Color(0xFFFFE4B5),
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

    // Bright golden center
    final centerPaint = Paint()..style = PaintingStyle.fill;

    centerPaint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 3.5 * bloom, centerPaint);

    centerPaint.color = const Color(0xFFFFA500);
    canvas.drawCircle(Offset.zero, 2 * bloom, centerPaint);

    canvas.restore();
  }

  @override
  List<Color> getLeafColors() {
    return const [
      Color(0xFF9CCC65),
      Color(0xFF7CB342),
      Color(0xFF558B2F),
    ];
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Magical sparkle particles
    _drawMagicalSparkles(canvas, centerX, groundY, trunkHeight);

    // Golden light rays
    _drawLightRays(canvas, centerX, groundY, trunkHeight);
  }

  void _drawMagicalSparkles(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final sparklePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (elapsedTime * 0.8 + i * 0.5) % (math.pi * 2);
      final radius = 80 + (i % 3) * 25;
      final bobbing = math.sin(elapsedTime * 3 + i * 0.8) * 15;

      final x = centerX + math.cos(angle) * radius;
      final y =
          groundY - height * 0.6 + math.sin(angle) * radius * 0.5 + bobbing;

      // Twinkle effect
      final twinkle = (math.sin(elapsedTime * 5 + i * 1.5) + 1) / 2;
      final sparkleSize = 2 + twinkle * 3;

      // Glow
      sparklePaint.color = const Color(
        0xFFFFD700,
      ).withValues(alpha: 0.3 * twinkle);
      canvas.drawCircle(Offset(x, y), sparkleSize, sparklePaint);

      // Core
      sparklePaint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.9);
      canvas.drawCircle(Offset(x, y), sparkleSize * 0.4, sparklePaint);

      // Star rays
      if (twinkle > 0.7) {
        final rayPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: twinkle * 0.6)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

        for (int j = 0; j < 4; j++) {
          final rayAngle = (j * math.pi / 2) + elapsedTime * 2;
          final rayLength = sparkleSize * 2;
          canvas.drawLine(
            Offset(x, y),
            Offset(
              x + math.cos(rayAngle) * rayLength,
              y + math.sin(rayAngle) * rayLength,
            ),
            rayPaint,
          );
        }
      }
    }
  }

  void _drawLightRays(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + elapsedTime * 0.5;
      final pulse = (math.sin(elapsedTime * 2 + i) + 1) / 2;
      final opacity = 0.03 * pulse;

      rayPaint.color = const Color(0xFFFFD700).withValues(alpha: opacity);

      final rayPath = Path()
        ..moveTo(centerX, groundY - height * 0.5)
        ..lineTo(
          centerX + math.cos(angle) * 100,
          groundY - height * 0.5 + math.sin(angle) * 100,
        )
        ..lineTo(
          centerX + math.cos(angle + 0.2) * 100,
          groundY - height * 0.5 + math.sin(angle + 0.2) * 100,
        )
        ..close();

      canvas.drawPath(rayPath, rayPaint);
    }
  }
}
