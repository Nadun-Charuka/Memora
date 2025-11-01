import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';

import 'base_stage_painter.dart';

/// Seedling Stage (0-5 memories)
/// A tender young sprout with first delicate leaves
class SeedlingPainter extends BaseTreeStagePainter {
  SeedlingPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.seedling;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Very thin, delicate stem
    final stemPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF4A7C59),
              const Color(0xFF7CB342),
              const Color(0xFF9CCC65),
            ],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    // Curved stem path
    final stemPath = Path()
      ..moveTo(centerX - width * 0.5, groundY)
      ..quadraticBezierTo(
        centerX + sway * 0.5,
        groundY - height * 0.5,
        centerX - width * 0.3 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.3 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + sway * 0.5,
        groundY - height * 0.5,
        centerX + width * 0.5,
        groundY,
      )
      ..close();

    canvas.drawPath(stemPath, stemPaint);
  }

  @override
  void drawLeafCluster(
    Canvas canvas,
    Offset center,
    BranchConfig config,
  ) {
    // Override to draw baby leaves differently
    _drawYoungLeaf(canvas, center, config.leafSize, config.angle);
  }

  void _drawYoungLeaf(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9CCC65),
          const Color(0xFF7CB342),
          const Color(0xFF558B2F),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));

    // Simple oval leaf
    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.6, -size * 0.2, size * 0.7, size * 0.1)
      ..quadraticBezierTo(size * 0.5, size * 0.3, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.5, size * 0.3, -size * 0.7, size * 0.1)
      ..quadraticBezierTo(-size * 0.6, -size * 0.2, 0, -size * 0.5);

    canvas.drawPath(path, leafPaint);

    // Simple vein
    final veinPaint = Paint()
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, -size * 0.4),
      Offset(0, size * 0.4),
      veinPaint,
    );

    canvas.restore();
  }

  @override
  List<Color> getBranchColors() {
    return const [
      Color(0xFF7CB342),
      Color(0xFF9CCC65),
    ];
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Gentle sparkles around the sprout
    _drawGrowthSparkles(canvas, centerX, groundY - trunkHeight);
  }

  void _drawGrowthSparkles(Canvas canvas, double x, double y) {
    final sparklePaint = Paint()
      ..color = const Color(0xFF9CCC65).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (elapsedTime * 2 + i * 2) % (math.pi * 2);
      final distance = 20 + math.sin(elapsedTime * 3 + i) * 5;
      final sparkleX = x + math.cos(angle) * distance;
      final sparkleY = y + math.sin(angle) * distance;

      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        2,
        sparklePaint,
      );
    }
  }
}
