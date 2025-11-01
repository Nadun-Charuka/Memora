import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';

import 'base_stage_painter.dart';

/// Growing Stage (10-18 memories)
/// Wild, energetic growth with asymmetric branches
class GrowingPainter extends BaseTreeStagePainter {
  GrowingPainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.growing;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Youthful trunk with visible growth energy
    final trunkPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF6D4C41),
              const Color(0xFF8D6E63),
              const Color(0xFF7D5E54),
              const Color(0xFF6D4C41),
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

    // Slightly curved trunk showing youthful flexibility
    final path = Path()
      ..moveTo(centerX - width * 0.7, groundY + 3)
      ..quadraticBezierTo(
        centerX - width * 0.5,
        groundY - height * 0.2,
        centerX - width * 0.4 + sway * 0.5,
        groundY - height * 0.5,
      )
      ..quadraticBezierTo(
        centerX - width * 0.3 + sway * 0.8,
        groundY - height * 0.75,
        centerX - width * 0.28 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.28 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.3 + sway * 0.8,
        groundY - height * 0.75,
        centerX + width * 0.4 + sway * 0.5,
        groundY - height * 0.5,
      )
      ..quadraticBezierTo(
        centerX + width * 0.5,
        groundY - height * 0.2,
        centerX + width * 0.7,
        groundY + 3,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Young bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 20) {
      final curve = math.sin(i * 0.3) * 2;
      canvas.drawLine(
        Offset(centerX - width * 0.25 + curve, groundY - i),
        Offset(centerX + width * 0.2 + curve, groundY - i - 10),
        barkPaint,
      );
    }

    // Add green vitality tint
    final vitalityPaint = Paint()
      ..color = const Color(0xFF7CB342).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, vitalityPaint);
  }

  @override
  List<Color> getBranchColors() {
    return const [
      Color(0xFF6D4C41),
      Color(0xFF8D6E63),
      Color(0xFF9D7E73),
    ];
  }

  @override
  List<Color> getLeafColors() {
    return const [
      Color(0xFFA5D6A7), // Fresh light green
      Color(0xFF81C784), // Medium green
      Color(0xFF66BB6A), // Vibrant green
    ];
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Occasional leaf particles falling/floating
    _drawFloatingLeafParticles(canvas, centerX, groundY, trunkHeight);
  }

  void _drawFloatingLeafParticles(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final leafPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final progress = (elapsedTime * 0.3 + i * 0.25) % 1.0;
      final x = centerX + (i % 2 == 0 ? -1 : 1) * (30 + i * 15);
      final y = groundY - height * 0.8 + (progress * height * 0.6);
      final drift = math.sin(progress * math.pi * 4 + i) * 15;
      final rotation = progress * math.pi * 2;
      final opacity = math.sin(progress * math.pi) * 0.5;

      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate(rotation);

      leafPaint.color = const Color(0xFF81C784).withValues(alpha: opacity);

      final leafPath = Path()
        ..moveTo(0, -4)
        ..quadraticBezierTo(3, -2, 3, 0)
        ..quadraticBezierTo(3, 2, 0, 4)
        ..quadraticBezierTo(-3, 2, -3, 0)
        ..quadraticBezierTo(-3, -2, 0, -4);

      canvas.drawPath(leafPath, leafPaint);
      canvas.restore();
    }
  }
}
