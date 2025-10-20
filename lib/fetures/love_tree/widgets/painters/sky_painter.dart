// FILE: lib/painters/sky_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class SkyPainter {
  final Animation<double> animation;

  SkyPainter({required this.animation});

  void paint(Canvas canvas, Size size) {
    _drawSkyGradient(canvas, size);
    _drawClouds(canvas, size);
  }

  void _drawSkyGradient(Canvas canvas, Size size) {
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF87CEEB), // Sky blue
        const Color(0xFFB0E0E6), // Powder blue
        const Color(0xFFFFE4B5), // Moccasin (horizon)
      ],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = skyGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Cloud 1 - slow, high altitude
    final cloud1X = (animation.value * 50) % (size.width + 300) - 150;
    final cloud1Y = 40 + math.sin(animation.value * 0.5) * 10;
    _drawCloud(canvas, Offset(cloud1X, cloud1Y), cloudPaint, 1.0);

    // Cloud 2 - medium speed, mid altitude
    final cloud2X =
        (animation.value * 80 + size.width * 0.3) % (size.width + 300) - 150;
    final cloud2Y = 90 + math.sin(animation.value * 0.7 + 1) * 15;
    _drawCloud(canvas, Offset(cloud2X, cloud2Y), cloudPaint, 0.8);

    // Cloud 3 - faster, lower altitude
    final cloud3X =
        (animation.value * 120 + size.width * 0.6) % (size.width + 300) - 150;
    final cloud3Y = 60 + math.sin(animation.value * 0.9 + 2) * 12;
    _drawCloud(canvas, Offset(cloud3X, cloud3Y), cloudPaint, 1.2);

    // Cloud 4 - very slow, drifting
    final cloud4X =
        (animation.value * 30 + size.width * 0.15) % (size.width + 300) - 150;
    final cloud4Y = 110 + math.sin(animation.value * 0.3 + 3) * 8;
    _drawCloud(canvas, Offset(cloud4X, cloud4Y), cloudPaint, 0.9);
  }

  void _drawCloud(Canvas canvas, Offset position, Paint paint, double scale) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);

    canvas.drawCircle(Offset.zero, 20, paint);
    canvas.drawCircle(Offset(15, -5), 25, paint);
    canvas.drawCircle(Offset(30, 0), 20, paint);
    canvas.drawCircle(Offset(20, 5), 22, paint);
    canvas.drawCircle(Offset(-10, 2), 18, paint);

    canvas.restore();
  }
}
