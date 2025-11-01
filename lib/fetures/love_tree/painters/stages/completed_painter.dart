import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';
import 'base_stage_painter.dart';

/// Completed Stage (60 memories)
/// Celebratory masterpiece with maximum visual splendor
class CompletedPainter extends BaseTreeStagePainter {
  CompletedPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.completed;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Magnificent trunk with golden undertones
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
      ..moveTo(centerX - width * 0.9, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.7,
        groundY - height * 0.15,
        centerX - width * 0.55,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.35 + sway * 0.6,
        groundY - height * 0.7,
        centerX - width * 0.3 + sway * 0.8,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.3 + sway * 0.8, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.35 + sway * 0.6,
        groundY - height * 0.7,
        centerX + width * 0.55,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX + width * 0.7,
        groundY - height * 0.15,
        centerX + width * 0.9,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Refined bark texture with golden hints
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

    // Golden highlights
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 45) {
      canvas.drawLine(
        Offset(centerX - width * 0.2, groundY - i - 10),
        Offset(centerX + width * 0.15, groundY - i - 16),
        highlightPaint,
      );
    }

    // Glowing moss accents
    final mossGlowPaint = Paint()
      ..color = const Color(0xFF9CCC65).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final random = math.Random(42);
    for (int i = 0; i < 10; i++) {
      final mossY = groundY - (random.nextDouble() * height * 0.7);
      final mossX = centerX + (random.nextDouble() - 0.5) * width * 1.3;
      canvas.drawCircle(
        Offset(mossX, mossY),
        5 + random.nextDouble() * 4,
        mossGlowPaint,
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
    // Epic celebration glow
    final glowPulse = (math.sin(elapsedTime * math.pi * 2) + 1) / 2;

    // Outer rainbow aura
    final rainbowGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF69B4), // Pink
      const Color(0xFF87CEEB), // Sky blue
    ];

    for (int i = 0; i < 3; i++) {
      rainbowGlow.color = colors[i].withValues(alpha: 0.06 * glowPulse);
      canvas.drawCircle(
        Offset(centerX, groundY - trunkHeight * 0.5),
        180 - (i * 20),
        rainbowGlow,
      );
    }

    // Inner golden core
    final coreGlow = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.15 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(
      Offset(centerX, groundY - trunkHeight * 0.5),
      100,
      coreGlow,
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

      // High percentage of golden leaves
      final isGolden = i % 3 == 0;
      final leafSize = config.leafSize + random.nextDouble() * 5;

      if (i % 6 == 0) {
        // Radiant flowers
        final bloom = 1.0;
        _drawCelebrationFlower(canvas, leafPos, bloom);
      } else {
        drawSingleLeaf(canvas, leafPos, leafSize, angle, isGolden);
      }
    }
  }

  void _drawCelebrationFlower(Canvas canvas, Offset center, double bloom) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Rainbow glow
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final glowPulse = (math.sin(elapsedTime * math.pi * 3) + 1) / 2;
    glowPaint.color = const Color(
      0xFFFFD700,
    ).withValues(alpha: 0.3 * glowPulse);
    canvas.drawCircle(Offset.zero, 10 * bloom, glowPaint);

    final petalPaint = Paint()..style = PaintingStyle.fill;

    // Prismatic petals
    for (int i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate((i * math.pi * 2 / 6));

      final petalColors = [
        const Color(0xFFFFD700),
        const Color(0xFFFF69B4),
        const Color(0xFF87CEEB),
      ];

      petalPaint.shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              petalColors[i % 3],
            ],
          ).createShader(
            Rect.fromLTWH(-6 * bloom, -12 * bloom, 12 * bloom, 12 * bloom),
          );

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          4 * bloom,
          -6 * bloom,
          2.5 * bloom,
          -11 * bloom,
        )
        ..quadraticBezierTo(
          0,
          -9 * bloom,
          -2.5 * bloom,
          -11 * bloom,
        )
        ..quadraticBezierTo(-4 * bloom, -6 * bloom, 0, 0);
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Sparkling center
    final centerPaint = Paint()..style = PaintingStyle.fill;

    centerPaint.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset.zero, 4 * bloom, centerPaint);

    centerPaint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 2.5 * bloom, centerPaint);

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
    // Epic celebration effects
    _drawCelebrationConfetti(canvas, centerX, groundY, trunkHeight);
    _drawFloatingHearts(canvas, centerX, groundY, trunkHeight);
    _drawPrismaticSparkles(canvas, centerX, groundY, trunkHeight);
  }

  void _drawCelebrationConfetti(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final confettiPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final progress = (elapsedTime * 0.4 + i * 0.15) % 1.0;
      final x =
          centerX + (i % 5 - 2) * 50 + math.sin(progress * math.pi * 5) * 30;
      final y = groundY - height * 1.1 + (progress * height * 1.2);
      final rotation = progress * math.pi * 8;
      final opacity = (1.0 - progress) * 0.8;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final confettiColors = [
        const Color(0xFFFFD700),
        const Color(0xFFFF69B4),
        const Color(0xFF87CEEB),
        const Color(0xFF9CCC65),
      ];

      confettiPaint.color = confettiColors[i % 4].withValues(alpha: opacity);

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 6, height: 10),
        confettiPaint,
      );

      canvas.restore();
    }
  }

  void _drawFloatingHearts(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final heartPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (elapsedTime * 0.6 + i) % (math.pi * 2);
      final radius = 90 + (i % 2) * 30;
      final bobbing = math.sin(elapsedTime * 2 + i * 1.5) * 20;

      final x = centerX + math.cos(angle) * radius;
      final y =
          groundY - height * 0.7 + math.sin(angle) * radius * 0.6 + bobbing;

      final pulse = (math.sin(elapsedTime * 4 + i * 2) + 1) / 2;
      final heartSize = 8 + pulse * 4;
      final opacity = 0.4 + pulse * 0.3;

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(heartSize / 10);

      heartPaint.color = const Color(0xFFFF69B4).withValues(alpha: opacity);

      final heartPath = Path()
        ..moveTo(0, 3)
        ..cubicTo(-5, -2, -5, -6, 0, -3)
        ..cubicTo(5, -6, 5, -2, 0, 3);

      canvas.drawPath(heartPath, heartPaint);
      canvas.restore();
    }
  }

  void _drawPrismaticSparkles(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final sparklePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final angle = (elapsedTime + i * 0.6) % (math.pi * 2);
      final radius = 100 + (i % 4) * 30;
      final bobbing = math.sin(elapsedTime * 4 + i * 1.2) * 25;

      final x = centerX + math.cos(angle) * radius;
      final y =
          groundY - height * 0.6 + math.sin(angle) * radius * 0.5 + bobbing;

      final twinkle = (math.sin(elapsedTime * 6 + i * 2) + 1) / 2;
      final sparkleSize = 2 + twinkle * 4;

      final sparkleColors = [
        const Color(0xFFFFD700),
        const Color(0xFFFF69B4),
        const Color(0xFF87CEEB),
        const Color(0xFFFFFFFF),
      ];

      // Glow
      sparklePaint.color = sparkleColors[i % 4].withValues(
        alpha: 0.3 * twinkle,
      );
      canvas.drawCircle(Offset(x, y), sparkleSize * 1.5, sparklePaint);

      // Core
      sparklePaint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.9);
      canvas.drawCircle(Offset(x, y), sparkleSize * 0.5, sparklePaint);

      // Star burst when bright
      if (twinkle > 0.75) {
        final rayPaint = Paint()
          ..color = sparkleColors[i % 4].withValues(alpha: twinkle * 0.7)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

        for (int j = 0; j < 8; j++) {
          final rayAngle = (j * math.pi / 4) + elapsedTime * 3;
          final rayLength = sparkleSize * 3;
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
}
