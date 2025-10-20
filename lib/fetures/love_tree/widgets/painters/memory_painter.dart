// FILE: lib/painters/memory_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/models/tree_model.dart';

class MemoryPainter {
  final Animation<double> animation;
  final LoveTree tree;
  final List<Memory> memories;

  MemoryPainter({
    required this.animation,
    required this.tree,
    required this.memories,
  });

  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    if (memories.isEmpty) return;

    final trunkHeight =
        tree.height *
        (tree.stage == TreeStage.seedling
            ? 2
            : tree.stage == TreeStage.growing
            ? 1.5
            : tree.stage == TreeStage.blooming
            ? 1.2
            : 1.0);

    // Group memories by emotion
    final birdMemories = memories
        .where((m) => m.emotion == MemoryEmotion.excited)
        .toList();
    final starMemories = memories
        .where((m) => m.emotion == MemoryEmotion.grateful)
        .toList();
    final rainMemories = memories
        .where((m) => m.emotion == MemoryEmotion.sad)
        .toList();
    final fruitMemories = memories
        .where((m) => m.emotion == MemoryEmotion.joyful)
        .toList();
    final otherMemories = memories
        .where(
          (m) =>
              m.emotion != MemoryEmotion.excited &&
              m.emotion != MemoryEmotion.grateful &&
              m.emotion != MemoryEmotion.sad &&
              m.emotion != MemoryEmotion.joyful,
        )
        .toList();

    for (int i = 0; i < birdMemories.length; i++) {
      _drawFlyingBird(canvas, size, i, birdMemories.length);
    }
    for (int i = 0; i < starMemories.length; i++) {
      _drawTwinklingStar(canvas, size, i, starMemories.length);
    }
    for (int i = 0; i < rainMemories.length; i++) {
      _drawFallingRain(canvas, size, i, rainMemories.length);
    }
    for (int i = 0; i < fruitMemories.length; i++) {
      _drawHangingFruit(
        canvas,
        size,
        centerX,
        groundY,
        trunkHeight,
        i,
        fruitMemories.length,
      );
    }
    for (int i = 0; i < otherMemories.length; i++) {
      _drawTreeMemory(
        canvas,
        size,
        centerX,
        groundY,
        trunkHeight,
        otherMemories[i],
        i,
        otherMemories.length,
      );
    }
  }

  // ALL your memory helper methods go here now.
  // ... _drawFlyingBird, _drawWing, _drawTwinklingStar, etc. ...
  // (Paste all the original methods from your old painter here)

  // NOTE: I've included all the methods below for you to copy.
  //<editor-fold desc="Memory Drawing Methods">
  void _drawFlyingBird(Canvas canvas, Size size, int index, int total) {
    // --- COLOR PALETTE CODE (Stays the same) ---
    final colorPalettes = [
      [
        const Color(0xFF4A90E2),
        const Color(0xFF87CEEB),
        const Color(0xFF4A90E2),
        const Color(0xFFF5A623),
      ], // Bluebird
      [
        const Color(0xFFD0021B),
        const Color(0xFFFF6347),
        const Color(0xFFD0021B),
        const Color(0xFFE27A3F),
      ], // Cardinal
      [
        const Color(0xFF417505),
        const Color(0xFF7ED321),
        const Color(0xFF417505),
        const Color(0xFFB8E986),
      ], // Green Jay
      [
        const Color(0xFF9013FE),
        const Color(0xFFBD10E0),
        const Color(0xFF9013FE),
        const Color(0xFFFFD700),
      ], // Purple Martin
      [
        const Color(0xFFF5A623),
        const Color(0xFFF8E71C),
        const Color(0xFFF5A623),
        const Color(0xFFE27A3F),
      ], // Goldfinch
    ];
    final palette = colorPalettes[index % colorPalettes.length];
    final bodyColor1 = palette[0];
    final bodyColor2 = palette[1];
    final wingColor = palette[2];
    final beakColor = palette[3];

    // --- START OF MODIFICATIONS ---

    // 1. Determine a consistent direction for each bird.
    // Even index birds fly right, odd index birds fly left.
    final bool isFlyingRight = index % 2 == 0;

    // Speed and position logic
    final birdSpeed = 0.3 + (index * 0.2);
    final flightProgress =
        (animation.value * birdSpeed + (index / total)) % 1.0;

    // 2. Calculate the 'x' position based on the direction.
    final double x;
    if (isFlyingRight) {
      // Fly Left-to-Right (0 -> screen width)
      x = size.width * flightProgress;
    } else {
      // Fly Right-to-Left (screen width -> 0)
      x = size.width * (1.0 - flightProgress);
    }

    // Vertical position logic remains the same
    final pathVariation = (index % 3) * 2.0;
    final y =
        60.0 +
        (index * 35) +
        math.sin(flightProgress * math.pi * 4 + pathVariation) * 20 +
        math.sin(animation.value * math.pi * 2 + index) * 8;

    final baseSize = 18.0;
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(x, y);

    final tiltAngle = math.sin(animation.value * math.pi * 2 + index) * 0.1;
    canvas.rotate(tiltAngle);

    // 3. Flip the entire bird drawing if it's flying left.
    if (!isFlyingRight) {
      canvas.scale(-1.0, 1.0); // This mirrors the canvas horizontally
    }

    // --- END OF MODIFICATIONS ---

    final wingFlap =
        math.sin(animation.value * math.pi * 12 + index * 0.5) * 0.6;
    final bodyScale = 1.0 + wingFlap.abs() * 0.08;
    canvas.scale(bodyScale, 1.0);

    // --- (The rest of the bird drawing code is exactly the same) ---

    // BIRD BODY
    paint.shader =
        LinearGradient(
          colors: [bodyColor1, bodyColor2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(
            -baseSize * 0.5,
            -baseSize * 0.25,
            baseSize,
            baseSize * 0.5,
          ),
        );
    final bodyPath = Path()
      ..moveTo(-baseSize * 0.3, 0)
      ..quadraticBezierTo(
        -baseSize * 0.45,
        -baseSize * 0.25,
        -baseSize * 0.5,
        -baseSize * 0.1,
      )
      ..quadraticBezierTo(
        -baseSize * 0.55,
        baseSize * 0.2,
        -baseSize * 0.3,
        baseSize * 0.25,
      )
      ..quadraticBezierTo(baseSize * 0.2, baseSize * 0.25, baseSize * 0.4, 0)
      ..quadraticBezierTo(baseSize * 0.2, -baseSize * 0.25, -baseSize * 0.3, 0)
      ..close();
    canvas.drawPath(bodyPath, paint);
    paint.shader = null;

    // HEAD
    paint.color = bodyColor2;
    canvas.drawCircle(
      Offset(baseSize * 0.35, -baseSize * 0.05),
      baseSize * 0.2,
      paint,
    );

    // EYE
    paint.color = Colors.black.withOpacity(0.7);
    canvas.drawCircle(
      Offset(baseSize * 0.45, -baseSize * 0.1),
      baseSize * 0.04,
      paint,
    );

    // BEAK
    paint.color = beakColor;
    final beakPath = Path()
      ..moveTo(baseSize * 0.48, -baseSize * 0.05)
      ..lineTo(baseSize * 0.65, 0)
      ..lineTo(baseSize * 0.48, baseSize * 0.05)
      ..close();
    canvas.drawPath(beakPath, paint);
    paint.color = Colors.white.withOpacity(0.5);
    final beakHighlightPath = Path()
      ..moveTo(baseSize * 0.5, -baseSize * 0.03)
      ..lineTo(baseSize * 0.6, 0)
      ..lineTo(baseSize * 0.5, baseSize * 0.03)
      ..close();
    canvas.drawPath(beakHighlightPath, paint);

    // WINGS
    canvas.scale(1.0 / bodyScale, 1.0);
    paint.color = wingColor;
    final wingBaseAngle = -0.6;
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05);
    canvas.rotate(wingBaseAngle + wingFlap);
    _drawWing(canvas, baseSize, paint);
    canvas.restore();
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05);
    canvas.rotate(-(wingBaseAngle + wingFlap));
    canvas.scale(1, -1);
    _drawWing(canvas, baseSize, paint);
    canvas.restore();
    canvas.scale(bodyScale, 1.0);

    // TAIL FEATHERS
    paint.color = bodyColor1.withOpacity(0.9);
    final tailPathCenter = Path()
      ..moveTo(-baseSize * 0.45, 0)
      ..lineTo(-baseSize * 0.65, -baseSize * 0.1)
      ..lineTo(-baseSize * 0.55, 0)
      ..lineTo(-baseSize * 0.65, baseSize * 0.1)
      ..close();
    canvas.drawPath(tailPathCenter, paint);
    final tailPaintThin = Paint()
      ..color = bodyColor1.withOpacity(0.8)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-baseSize * 0.45, 0),
      Offset(-baseSize * 0.6, -baseSize * 0.15),
      tailPaintThin,
    );
    canvas.drawLine(
      Offset(-baseSize * 0.45, 0),
      Offset(-baseSize * 0.6, baseSize * 0.15),
      tailPaintThin,
    );

    canvas.restore();
  }

  void _drawWing(Canvas canvas, double baseSize, Paint paint) {
    final wingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        baseSize * 0.3,
        -baseSize * 0.4,
        baseSize * 0.8,
        -baseSize * 0.3,
      )
      ..quadraticBezierTo(baseSize * 0.5, -baseSize * 0.1, baseSize * 0.4, 0)
      ..close();
    canvas.drawPath(wingPath, paint);
    paint.color = Colors.black.withOpacity(0.2);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(baseSize * 0.2, -baseSize * 0.05),
      Offset(baseSize * 0.6, -baseSize * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(baseSize * 0.15, 0),
      Offset(baseSize * 0.5, -baseSize * 0.15),
      paint,
    );
    paint.style = PaintingStyle.fill;
  }

  void _drawTwinklingStar(Canvas canvas, Size size, int index, int total) {
    final x = (size.width / (total + 1)) * (index + 1);
    final y = 40.0 + (index % 3) * 30;
    final iconSize = 15.0;
    final twinkle =
        (math.sin(animation.value * math.pi * 4 + index * 2) + 1) / 2;
    final scale = 0.7 + twinkle * 0.6;
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.8 + twinkle * 0.2)
      ..style = PaintingStyle.fill;
    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * math.pi * 2 / 5) - math.pi / 2;
      final outerRadius = iconSize * 0.5;
      final innerRadius = iconSize * 0.2;
      final outerX = math.cos(angle) * outerRadius;
      final outerY = math.sin(angle) * outerRadius;
      if (i == 0) {
        starPath.moveTo(outerX, outerY);
      } else {
        starPath.lineTo(outerX, outerY);
      }
      final innerAngle = angle + (math.pi / 5);
      final innerX = math.cos(innerAngle) * innerRadius;
      final innerY = math.sin(innerAngle) * innerRadius;
      starPath.lineTo(innerX, innerY);
    }
    starPath.close();
    canvas.drawPath(starPath, paint);
    paint
      ..color = const Color(0xFFFFD700).withOpacity(0.3 * twinkle)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(starPath, paint);
    canvas.restore();
  }

  void _drawFallingRain(Canvas canvas, Size size, int index, int total) {
    final x = (size.width / (total + 1)) * (index + 1);
    final fallSpeed = 0.5 + (index * 0.15);
    final fallProgress = (animation.value * fallSpeed) % 1.0;
    final startY = size.height * 0.1;
    final endY = size.height * 0.85;
    final y = startY + ((endY - startY) * fallProgress);
    final iconSize = 8.0;
    final paint = Paint()..style = PaintingStyle.fill;
    final drift = math.sin(fallProgress * math.pi * 3) * 10;
    canvas.save();
    canvas.translate(x + drift, y);
    final opacity = 0.5 + (fallProgress * 0.4);
    paint.color = const Color(0xFF4682B4).withOpacity(opacity);
    final dropPath = Path()
      ..moveTo(0, -iconSize)
      ..quadraticBezierTo(
        iconSize * 0.5,
        -iconSize * 0.3,
        iconSize * 0.3,
        iconSize * 0.3,
      )
      ..quadraticBezierTo(0, iconSize * 0.6, 0, iconSize * 0.7)
      ..quadraticBezierTo(0, iconSize * 0.6, -iconSize * 0.3, iconSize * 0.3)
      ..quadraticBezierTo(-iconSize * 0.5, -iconSize * 0.3, 0, -iconSize);
    canvas.drawPath(dropPath, paint);
    paint.color = Colors.white.withOpacity(0.5 * opacity);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.4),
      iconSize * 0.18,
      paint,
    );
    if (fallProgress > 0.92) {
      final splashProgress = (fallProgress - 0.92) / 0.08;
      final splashSize = splashProgress * iconSize * 1.5;
      paint.color = const Color(
        0xFF4682B4,
      ).withOpacity(0.4 * (1 - splashProgress));
      for (int i = 0; i < 4; i++) {
        final angle = (i / 4) * math.pi * 2;
        final splashOffset = Offset(
          math.cos(angle) * splashSize,
          iconSize * 0.7 + math.sin(angle) * splashSize * 0.3,
        );
        canvas.drawCircle(splashOffset, splashSize * 0.3, paint);
      }
    }
    canvas.restore();
  }

  void _drawHangingFruit(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY,
    double trunkHeight,
    int index,
    int total,
  ) {
    final angle = (index / total) * math.pi * 2;
    final radius = 60.0 + (index % 3) * 20;
    final x = centerX + math.cos(angle) * radius;
    final y = groundY - trunkHeight * 0.6 + math.sin(angle) * 30;
    final iconSize = 15.0;
    final swing = math.sin(animation.value * math.pi * 2 + index) * 3;
    canvas.save();
    canvas.translate(x + swing, y);
    final stemPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -iconSize * 0.5),
      Offset(0, -iconSize * 0.8),
      stemPaint,
    );
    final fruitPaint = Paint()
      ..color = const Color(0xFFFF6347)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, iconSize * 0.45, fruitPaint);
    fruitPaint.color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.15),
      iconSize * 0.15,
      fruitPaint,
    );
    final leafPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(iconSize * 0.1, -iconSize * 0.6),
        width: iconSize * 0.3,
        height: iconSize * 0.2,
      ),
      leafPaint,
    );
    canvas.restore();
  }

  void _drawTreeMemory(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY,
    double trunkHeight,
    Memory memory,
    int index,
    int total,
  ) {
    final spiralTurns = (index / total) * 2.5;
    final angle = spiralTurns * math.pi * 2;
    final radiusProgress = (index / total);
    double maxRadius = 80.0;
    double yOffset = trunkHeight * 0.6;
    if (tree.stage == TreeStage.seedling) {
      maxRadius = 25.0;
      yOffset = trunkHeight * 0.5;
    } else if (tree.stage == TreeStage.growing) {
      maxRadius = 50.0;
      yOffset = trunkHeight * 0.6;
    } else if (tree.stage == TreeStage.blooming) {
      maxRadius = 80.0;
      yOffset = trunkHeight * 0.7;
    }
    final radius = 15 + (radiusProgress * maxRadius);
    final x = centerX + math.cos(angle) * radius;
    final y = groundY - yOffset + math.sin(angle) * radius * 0.3;
    _drawMemoryIcon(canvas, Offset(x, y), memory.emotion);
  }

  void _drawMemoryIcon(Canvas canvas, Offset position, MemoryEmotion emotion) {
    final iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(position.dx, position.dy);
    final scale = 1.0 + (math.sin(animation.value * math.pi * 2) * 0.1);
    canvas.scale(scale);
    switch (emotion) {
      case MemoryEmotion.happy:
        paint.color = const Color(0xFFFFB6C1);
        final petalRotation = animation.value * 0.2;
        for (int i = 0; i < 6; i++) {
          canvas.save();
          canvas.rotate((i * math.pi * 2 / 6) + petalRotation);
          final petalPath = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(
              iconSize * 0.15,
              -iconSize * 0.3,
              0,
              -iconSize * 0.5,
            )
            ..quadraticBezierTo(-iconSize * 0.15, -iconSize * 0.3, 0, 0);
          canvas.drawPath(petalPath, paint);
          canvas.restore();
        }
        paint.color = const Color(0xFFFFD700);
        canvas.drawCircle(Offset.zero, iconSize * 0.2, paint);
        paint.color = const Color(0xFFFFB700);
        for (int i = 0; i < 8; i++) {
          final angle = (i / 8) * math.pi * 2;
          canvas.drawCircle(
            Offset(
              math.cos(angle) * iconSize * 0.12,
              math.sin(angle) * iconSize * 0.12,
            ),
            iconSize * 0.03,
            paint,
          );
        }
        break;
      case MemoryEmotion.love:
        final heartBeat = 1.0 + math.sin(animation.value * math.pi * 4) * 0.15;
        canvas.scale(heartBeat);
        paint.color = const Color(0xFFFF1493);
        final heartPath = Path()
          ..moveTo(0, iconSize * 0.3)
          ..cubicTo(
            -iconSize * 0.5,
            -iconSize * 0.1,
            -iconSize * 0.5,
            -iconSize * 0.5,
            0,
            -iconSize * 0.2,
          )
          ..cubicTo(
            iconSize * 0.5,
            -iconSize * 0.5,
            iconSize * 0.5,
            -iconSize * 0.1,
            0,
            iconSize * 0.3,
          );
        canvas.drawPath(heartPath, paint);
        paint.color = const Color(0xFFFFFFFF).withOpacity(0.8);
        final sparkleAngle = animation.value * math.pi * 4;
        for (int i = 0; i < 4; i++) {
          final angle = (i * math.pi / 2) + sparkleAngle;
          final sparkleOffset = Offset(
            math.cos(angle) * iconSize * 0.8,
            math.sin(angle) * iconSize * 0.8,
          );
          canvas.drawCircle(sparkleOffset, iconSize * 0.08, paint);
        }
        break;
      case MemoryEmotion.nostalgic:
        final flutter = math.sin(animation.value * math.pi * 6) * 0.3;
        paint.color = const Color(0xFFBA55D3);
        canvas.save();
        canvas.rotate(flutter);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-iconSize * 0.3, -iconSize * 0.1),
            width: iconSize * 0.5,
            height: iconSize * 0.7,
          ),
          paint,
        );
        canvas.restore();
        canvas.save();
        canvas.rotate(-flutter);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(iconSize * 0.3, -iconSize * 0.1),
            width: iconSize * 0.5,
            height: iconSize * 0.7,
          ),
          paint,
        );
        canvas.restore();
        paint.color = const Color(0xFFFFFFFF).withOpacity(0.4);
        canvas.drawCircle(
          Offset(-iconSize * 0.25, -iconSize * 0.15),
          iconSize * 0.12,
          paint,
        );
        canvas.drawCircle(
          Offset(iconSize * 0.25, -iconSize * 0.15),
          iconSize * 0.12,
          paint,
        );
        paint.color = const Color(0xFF000000);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, 0),
            width: iconSize * 0.15,
            height: iconSize * 0.6,
          ),
          paint,
        );
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawLine(
          Offset(0, -iconSize * 0.3),
          Offset(-iconSize * 0.15, -iconSize * 0.5),
          paint,
        );
        canvas.drawLine(
          Offset(0, -iconSize * 0.3),
          Offset(iconSize * 0.15, -iconSize * 0.5),
          paint,
        );
        paint.style = PaintingStyle.fill;
        break;
      case MemoryEmotion.peaceful:
        final leafSway = math.sin(animation.value * math.pi * 2) * 0.2;
        canvas.rotate(leafSway);
        paint.color = const Color(0xFF4A7C59);
        final leafPath = Path()
          ..moveTo(0, -iconSize * 0.5)
          ..quadraticBezierTo(
            iconSize * 0.3,
            -iconSize * 0.3,
            iconSize * 0.25,
            0,
          )
          ..quadraticBezierTo(iconSize * 0.3, iconSize * 0.3, 0, iconSize * 0.5)
          ..quadraticBezierTo(
            -iconSize * 0.3,
            iconSize * 0.3,
            -iconSize * 0.25,
            0,
          )
          ..quadraticBezierTo(
            -iconSize * 0.3,
            -iconSize * 0.3,
            0,
            -iconSize * 0.5,
          );
        canvas.drawPath(leafPath, paint);
        paint.color = const Color(0xFF228B22);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawLine(
          Offset(0, -iconSize * 0.5),
          Offset(0, iconSize * 0.5),
          paint,
        );
        for (double i = -0.3; i <= 0.3; i += 0.15) {
          canvas.drawLine(
            Offset(0, iconSize * i),
            Offset(iconSize * 0.2, iconSize * (i + 0.1)),
            paint,
          );
          canvas.drawLine(
            Offset(0, iconSize * i),
            Offset(-iconSize * 0.2, iconSize * (i + 0.1)),
            paint,
          );
        }
        paint.style = PaintingStyle.fill;
        break;
      case MemoryEmotion.excited:
      case MemoryEmotion.joyful:
      case MemoryEmotion.grateful:
      case MemoryEmotion.sad:
        break;
    }
    canvas.restore();
  }

  //</editor-fold>
}
