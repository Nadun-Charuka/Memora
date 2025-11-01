import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';

import 'base_stage_painter.dart';

/// Flourishing Stage (18-28 memories)
/// Dense, vibrant foliage with excellent health
class FlourishingPainter extends BaseTreeStagePainter {
  FlourishingPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.flourishing;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Strong, established trunk
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

    // Strong, slightly curved trunk
    final path = Path()
      ..moveTo(centerX - width * 0.8, groundY + 4)
      ..quadraticBezierTo(
        centerX - width * 0.65,
        groundY - height * 0.15,
        centerX - width * 0.5,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.35 + sway * 0.7,
        groundY - height * 0.7,
        centerX - width * 0.3 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.3 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.35 + sway * 0.7,
        groundY - height * 0.7,
        centerX + width * 0.5,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX + width * 0.65,
        groundY - height * 0.15,
        centerX + width * 0.8,
        groundY + 4,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Defined bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 18) {
      final curve = math.sin(i * 0.25) * 2;
      canvas.drawLine(
        Offset(centerX - width * 0.25 + curve, groundY - i),
        Offset(centerX + width * 0.2 + curve, groundY - i - 9),
        barkPaint,
      );
    }

    // Add horizontal bark lines for texture
    for (double i = 15; i < height; i += 35) {
      canvas.drawLine(
        Offset(centerX - width * 0.3, groundY - i),
        Offset(centerX + width * 0.3, groundY - i),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.1)
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  List<Color> getBranchColors() {
    return const [
      Color(0xFF6D4C41),
      Color(0xFF8D6E63),
      Color(0xFFA1887F),
    ];
  }

  @override
  List<Color> getLeafColors() {
    return const [
      Color(0xFF8BC34A), // Bright lime green
      Color(0xFF7CB342), // Medium green
      Color(0xFF689F38), // Forest green
    ];
  }

  @override
  void paintBackgroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    super.paintBackgroundEffects(canvas, centerX, groundY, trunkHeight);

    // Add subtle aura of vitality
    final auraPaint = Paint()
      ..color = const Color(0xFF8BC34A).withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(
      Offset(centerX, groundY - trunkHeight * 0.5),
      100,
      auraPaint,
    );
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Fireflies around the lush canopy
    _drawFireflies(canvas, centerX, groundY, trunkHeight);
  }

  void _drawFireflies(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final fireflyPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (elapsedTime * 0.5 + i * 1.0) % (math.pi * 2);
      final orbitRadius = 60 + i * 15;
      final bobbing = math.sin(elapsedTime * 2 + i) * 10;

      final x = centerX + math.cos(angle) * orbitRadius;
      final y = groundY - height * 0.6 + math.sin(angle) * 40 + bobbing;

      // Glow pulse
      final pulse = (math.sin(elapsedTime * 4 + i * 2) + 1) / 2;
      final glowSize = 4 + pulse * 2;

      // Outer glow
      fireflyPaint.color = const Color(
        0xFFFFEB3B,
      ).withValues(alpha: 0.2 * pulse);
      canvas.drawCircle(Offset(x, y), glowSize, fireflyPaint);

      // Inner core
      fireflyPaint.color = const Color(0xFFFFEB3B).withValues(alpha: 0.8);
      canvas.drawCircle(Offset(x, y), 2, fireflyPaint);
    }
  }
}
