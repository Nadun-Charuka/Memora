import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';

import 'base_stage_painter.dart';

/// Sprouting Stage (5-10 memories)
/// First real branches emerging, youthful energy
class SproutingPainter extends BaseTreeStagePainter {
  SproutingPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.sprouting;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Young, flexible trunk with green tint
    final trunkPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF5A8A67),
              const Color(0xFF7AAC88),
              const Color(0xFF6B9B78),
              const Color(0xFF5A8A67),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    // Slightly curved trunk showing flexibility
    final path = Path()
      ..moveTo(centerX - width * 0.6, groundY + 2)
      ..quadraticBezierTo(
        centerX - width * 0.4,
        groundY - height * 0.3,
        centerX - width * 0.35 + sway * 0.6,
        groundY - height * 0.7,
      )
      ..lineTo(centerX - width * 0.3 + sway, groundY - height)
      ..lineTo(centerX + width * 0.3 + sway, groundY - height)
      ..lineTo(centerX + width * 0.35 + sway * 0.6, groundY - height * 0.7)
      ..quadraticBezierTo(
        centerX + width * 0.4,
        groundY - height * 0.3,
        centerX + width * 0.6,
        groundY + 2,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Young bark texture - minimal
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 25) {
      final curve = math.sin(i * 0.4) * 1.5;
      canvas.drawLine(
        Offset(centerX - width * 0.2 + curve, groundY - i),
        Offset(centerX + width * 0.15 + curve, groundY - i - 8),
        barkPaint,
      );
    }
  }

  @override
  List<Color> getBranchColors() {
    return const [
      Color(0xFF6B9B78),
      Color(0xFF8DAA9D),
      Color(0xFF7AAC88),
    ];
  }

  @override
  List<Color> getLeafColors() {
    return const [
      Color(0xFFA5D6A7),
      Color(0xFF81C784),
      Color(0xFF66BB6A),
    ];
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Growth particles rising from new branches
    _drawGrowthParticles(canvas, centerX, groundY, trunkHeight);
  }

  void _drawGrowthParticles(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final branch in schema.branches) {
      final branchY = groundY - height * branch.heightRatio;
      final branchX = centerX + branch.length * math.sin(branch.angle) * 0.8;

      // Particle animation
      for (int i = 0; i < 2; i++) {
        final progress = (elapsedTime * 0.5 + i * 0.5) % 1.0;
        final particleY = branchY - (progress * 30);
        final particleX = branchX + math.sin(progress * math.pi * 4) * 5;
        final opacity = (1.0 - progress) * 0.4;

        particlePaint.color = const Color(
          0xFF9CCC65,
        ).withValues(alpha: opacity);

        canvas.drawCircle(
          Offset(particleX, particleY),
          2 * (1.0 - progress),
          particlePaint,
        );
      }
    }
  }
}
