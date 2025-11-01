import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import '../ground_painter.dart';

/// Not Planted Stage
/// Waiting state with gentle invitation
class UnplantedPainter {
  final double elapsedTime;
  final LoveTree tree;
  final GroundPainter groundPainter;

  UnplantedPainter({
    required this.elapsedTime,
    required this.tree,
  }) : groundPainter = GroundPainter(elapsedTime: elapsedTime);

  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    // Glowing planting spot
    final glowPaint = Paint()
      ..color = const Color(0xFF6B5345).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(centerX, groundY + 20), 40, glowPaint);

    // Soil spot
    final spotPaint = Paint()
      ..color = const Color(0xFF6B5345)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, groundY + 20), 30, spotPaint);

    // Animated seed/sprout icon
    final scale = 1.0 + math.sin(elapsedTime * math.pi * 2) * 0.2;
    canvas.save();
    canvas.translate(centerX, groundY - 10);
    canvas.scale(scale);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🌱',
        style: TextStyle(fontSize: 40),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();

    // Sparkles around the spot
    _drawInvitingSparkles(canvas, centerX, groundY);
  }

  void _drawInvitingSparkles(Canvas canvas, double centerX, double groundY) {
    final sparklePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (elapsedTime * 2 + i * (math.pi * 2 / 6)) % (math.pi * 2);
      final distance = 50 + math.sin(elapsedTime * 3 + i) * 10;
      final x = centerX + math.cos(angle) * distance;
      final y = groundY + math.sin(angle) * distance * 0.5;

      final pulse = (math.sin(elapsedTime * 4 + i * 1.5) + 1) / 2;
      final size = 2 + pulse * 2;

      sparklePaint.color = const Color(
        0xFF9CCC65,
      ).withValues(alpha: 0.5 * pulse);
      canvas.drawCircle(Offset(x, y), size, sparklePaint);
    }
  }
}
