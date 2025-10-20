// FILE: lib/painters/ground_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class GroundPainter {
  final Animation<double> animation;

  GroundPainter({required this.animation});

  void paint(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );

    // More realistic animated grass with varying heights and colors
    final grassColors = [
      const Color(0xFF6B9B78),
      const Color(0xFF5A8A67),
      const Color(0xFF7AAC88),
      const Color(0xFF4A7C59),
    ];

    for (int i = 0; i < size.width; i += 8) {
      // Vary grass properties
      final grassIndex = i % 4;
      final baseHeight = 10.0 + (math.sin(i * 0.5) * 5).abs();
      final sway = math.sin(animation.value * math.pi * 2 + i * 0.1) * 3;

      final grassPaint = Paint()
        ..color = grassColors[grassIndex]
        ..strokeWidth = 1.5 + (grassIndex * 0.3)
        ..strokeCap = StrokeCap.round;

      // Main grass blade
      canvas.drawLine(
        Offset(i.toDouble(), groundY),
        Offset(i.toDouble() + sway, groundY - baseHeight),
        grassPaint,
      );

      // Add some grass blades with splits for more realism
      if (i % 16 == 0) {
        final splitHeight = baseHeight * 0.6;
        final splitSway = sway * 1.2;

        canvas.drawLine(
          Offset(i.toDouble() + sway, groundY - baseHeight),
          Offset(
            i.toDouble() + splitSway - 2,
            groundY - baseHeight - splitHeight,
          ),
          grassPaint,
        );

        canvas.drawLine(
          Offset(i.toDouble() + sway, groundY - baseHeight),
          Offset(
            i.toDouble() + splitSway + 2,
            groundY - baseHeight - splitHeight,
          ),
          grassPaint,
        );
      }
    }
  }
}
