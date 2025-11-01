// FILE: lib/painters/sky_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

class SkyPainter {
  final double elapsedTime; // CHANGED from Animation<double>
  late final List<CloudData> clouds;

  SkyPainter({required this.elapsedTime}) {
    // CHANGED
    clouds = [
      CloudData(
        baseSpeed: 25,
        yPosition: 0.08,
        scale: 1.2,
        opacity: 0.9,
        verticalFloat: 8,
        floatSpeed: 0.4,
        phaseOffset: 0,
      ),
      CloudData(
        baseSpeed: 40,
        yPosition: 0.25,
        scale: 0.85,
        opacity: 0.75,
        verticalFloat: 12,
        floatSpeed: 0.6,
        phaseOffset: 2.5,
      ),
      CloudData(
        baseSpeed: 18,
        yPosition: 0.15,
        scale: 1.0,
        opacity: 0.8,
        verticalFloat: 10,
        floatSpeed: 0.5,
        phaseOffset: 4.2,
      ),
      CloudData(
        baseSpeed: 55,
        yPosition: 0.35,
        scale: 0.7,
        opacity: 0.65,
        verticalFloat: 15,
        floatSpeed: 0.8,
        phaseOffset: 1.3,
      ),
      CloudData(
        baseSpeed: 32,
        yPosition: 0.12,
        scale: 1.1,
        opacity: 0.85,
        verticalFloat: 9,
        floatSpeed: 0.45,
        phaseOffset: 3.7,
      ),
      CloudData(
        baseSpeed: 70,
        yPosition: 0.28,
        scale: 0.4,
        opacity: 0.6,
        verticalFloat: 18,
        floatSpeed: 1.0,
        phaseOffset: 5.1,
      ),
    ];
  }

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
    const cloudWidth = 100.0;
    final totalDistance = size.width + cloudWidth * 2;

    for (int i = 0; i < clouds.length; i++) {
      final cloud = clouds[i];

      // CHANGED: Use elapsedTime instead of animation.value
      final rawProgress =
          (elapsedTime * cloud.baseSpeed +
              totalDistance * (i / clouds.length)) %
          totalDistance;
      final xPos = rawProgress - cloudWidth;

      // CHANGED: Use elapsedTime for vertical floating
      final yPos =
          size.height * cloud.yPosition +
          math.sin(elapsedTime * cloud.floatSpeed + cloud.phaseOffset) *
              cloud.verticalFloat;

      final cloudPaint = Paint()
        ..color = Colors.white.withValues(alpha: cloud.opacity)
        ..style = PaintingStyle.fill;

      _drawCloud(canvas, Offset(xPos, yPos), cloudPaint, cloud.scale);
    }
  }

  void _drawCloud(Canvas canvas, Offset position, Paint paint, double scale) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);

    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);
    canvas.drawCircle(const Offset(32, -3), 23, paint);
    canvas.drawCircle(const Offset(45, 2), 19, paint);
    canvas.drawCircle(const Offset(20, 6), 20, paint);
    canvas.drawCircle(const Offset(28, 8), 17, paint);

    canvas.restore();
  }
}

class CloudData {
  final double baseSpeed;
  final double yPosition;
  final double scale;
  final double opacity;
  final double verticalFloat;
  final double floatSpeed;
  final double phaseOffset;

  CloudData({
    required this.baseSpeed,
    required this.yPosition,
    required this.scale,
    required this.opacity,
    required this.verticalFloat,
    required this.floatSpeed,
    required this.phaseOffset,
  });
}
