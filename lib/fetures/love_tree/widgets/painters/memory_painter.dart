// FILE: lib/painters/memory_painter.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';

class MemoryPainter {
  final double elapsedTime;
  final LoveTree tree;
  final List<Memory> memories;

  MemoryPainter({
    required this.elapsedTime,
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
    final stormMemories = memories
        .where((m) => m.emotion == MemoryEmotion.awful)
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
    for (int i = 0; i < stormMemories.length; i++) {
      _drawStormCloud(canvas, size, i, stormMemories.length);
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
    final flightProgress = (elapsedTime * birdSpeed + (index / total)) % 1.0;

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
        math.sin(elapsedTime * math.pi * 2 + index) * 8;

    final baseSize = 18.0;
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(x, y);

    final tiltAngle = math.sin(elapsedTime * math.pi * 2 + index) * 0.1;
    canvas.rotate(tiltAngle);

    // 3. Flip the entire bird drawing if it's flying left.
    if (!isFlyingRight) {
      canvas.scale(-1.0, 1.0); // This mirrors the canvas horizontally
    }

    // --- END OF MODIFICATIONS ---

    final wingFlap = math.sin(elapsedTime * math.pi * 12 + index * 0.5) * 0.6;
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
    paint.color = Colors.black.withValues(alpha: 0.7);
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
    paint.color = Colors.white.withValues(alpha: 0.5);
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
    paint.color = bodyColor1.withValues(alpha: 0.9);
    final tailPathCenter = Path()
      ..moveTo(-baseSize * 0.45, 0)
      ..lineTo(-baseSize * 0.65, -baseSize * 0.1)
      ..lineTo(-baseSize * 0.55, 0)
      ..lineTo(-baseSize * 0.65, baseSize * 0.1)
      ..close();
    canvas.drawPath(tailPathCenter, paint);
    final tailPaintThin = Paint()
      ..color = bodyColor1.withValues(alpha: 0.8)
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
    paint.color = Colors.black.withValues(alpha: 0.2);
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
    final twinkle = (math.sin(elapsedTime * math.pi * 4 + index * 2) + 1) / 2;
    final scale = 0.7 + twinkle * 0.6;
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.8 + twinkle * 0.2)
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
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3 * twinkle)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(starPath, paint);
    canvas.restore();
  }

  void _drawFallingRain(Canvas canvas, Size size, int index, int total) {
    final x = (size.width / (total + 1)) * (index + 1);
    final fallSpeed = 0.5 + (index * 0.15);
    final fallProgress = (elapsedTime * fallSpeed) % 1.0;
    final startY = size.height * 0.1;
    final endY = size.height * 0.85;
    final y = startY + ((endY - startY) * fallProgress);
    final iconSize = 8.0;
    final paint = Paint()..style = PaintingStyle.fill;
    final drift = math.sin(fallProgress * math.pi * 3) * 10;
    canvas.save();
    canvas.translate(x + drift, y);
    final opacity = 0.5 + (fallProgress * 0.4);
    paint.color = const Color(0xFF4682B4).withValues(alpha: opacity);
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
    paint.color = Colors.white.withValues(alpha: 0.5 * opacity);
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
      ).withValues(alpha: 0.4 * (1 - splashProgress));
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

  void _drawStormCloud(Canvas canvas, Size size, int index, int total) {
    // --- NEW: Create a stable random generator for this cloud ---
    // We use the 'index' as the seed. This means cloud 'index' 0
    // will ALWAYS get the same random values, cloud 'index' 1
    // will always get its own set of random values, etc.
    // This stops the clouds from flickering!
    final random = math.Random(index);

    // --- NEW: Calculate a random scale ---
    final minScale = 0.4;
    final maxScale = 0.8;
    // This gives a random value between 0.4 and 0.8
    final cloudScale = minScale + random.nextDouble() * (maxScale - minScale);

    // Position clouds across the top of the screen
    final x = (size.width / (total + 1)) * (index + 1);

    // --- UPDATED: Use our random generator for a better 'y' position ---
    // This is better than (index % 2) because it looks more natural.
    // Gives a random height between 70.0 and 120.0
    final y = 70.0 + random.nextDouble() * 50.0;

    // --- DELETED ---
    // final cloudScale = 0.6; // We use our new random one instead

    final paint = Paint()..style = PaintingStyle.fill;

    // Lightning bolt (animated flash)
    // We add random.nextDouble() to make the lightning flash at different times
    final lightningFlash = (elapsedTime * 2 + random.nextDouble() * 3.0) % 3.0;
    final isLightning = lightningFlash < 0.2;

    // Animation: vibrate when lightning, gentle drift when not
    final double drift;
    if (isLightning) {
      // Rapid vibration during lightning
      final vibrate = math.sin(elapsedTime * math.pi * 40) * 3;
      drift = vibrate;
    } else {
      // Slow gentle drift when calm
      drift = math.sin(elapsedTime * 0.5 + index) * 50;
    }

    canvas.save();
    canvas.translate(x + drift, y);

    // Dark fade/shadow around cloud
    final shadowPaint = Paint()
      ..color = const Color(0xFF2D3748).withValues(alpha: 0.3)
      // --- UPDATED: Make shadow match the cloud size ---
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * cloudScale);
    canvas.drawCircle(Offset.zero, 40 * cloudScale, shadowPaint);

    // Draw storm cloud using your cloud shape
    canvas.scale(cloudScale);

    // Dark storm cloud color
    paint.color = const Color(0xFF4A5568).withValues(alpha: 0.7);

    // Your exact cloud shape from SkyPainter
    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);
    canvas.drawCircle(const Offset(32, -3), 23, paint);
    canvas.drawCircle(const Offset(45, 2), 19, paint);
    canvas.drawCircle(const Offset(20, 6), 20, paint);
    canvas.drawCircle(const Offset(28, 8), 17, paint);

    // Add darker texture/depth overlay
    paint.color = const Color(0xFF2D3748).withValues(alpha: 0.3);
    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);

    canvas.scale(1.0 / cloudScale); // Reset scale for lightning

    if (isLightning) {
      // Brief flash every 3 seconds
      final boltPaint = Paint()
        ..color = const Color(0xFFFFFACD).withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Jagged lightning bolt coming from cloud center
      final lightningPath = Path()
        ..moveTo(15, 8) // Start from bottom of cloud
        ..lineTo(20, 25)
        ..lineTo(15, 25)
        ..lineTo(22, 45)
        ..lineTo(17, 45)
        ..lineTo(25, 65);

      canvas.drawPath(lightningPath, boltPaint);

      // Lightning glow effect
      boltPaint
        ..color = const Color(0xFFFFFF00).withValues(alpha: 0.4)
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(lightningPath, boltPaint);

      // Flash on cloud itself
      canvas.scale(cloudScale);
      paint
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.15)
        ..maskFilter = null;
      canvas.drawCircle(const Offset(15, -8), 26, paint);
      canvas.drawCircle(const Offset(32, -3), 23, paint);
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
    final y = groundY - trunkHeight * 0.6 + math.sin(angle) * 60;
    final iconSize = 15.0;
    final swing = math.sin(elapsedTime * math.pi * 2 + index) * 3;
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
    fruitPaint.color = Colors.white.withValues(alpha: 0.4);
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
    // Only butterflies (nostalgic) fly around the tree
    if (memory.emotion == MemoryEmotion.nostalgic) {
      // Random circular orbit around tree
      final random = math.Random(index + 100);
      final orbitSpeed = 0.2 + (random.nextDouble() * 0.3);
      final orbitProgress = (elapsedTime * orbitSpeed + (index / total)) % 1.0;
      final angle = orbitProgress * math.pi * 2;

      // Wider orbit radius based on tree stage
      double maxRadius = 120.0;
      double yCenter = trunkHeight * 0.6;
      if (tree.stage == TreeStage.seedling) {
        maxRadius = 40.0;
        yCenter = trunkHeight * 0.5;
      } else if (tree.stage == TreeStage.growing) {
        maxRadius = 80.0;
        yCenter = trunkHeight * 0.6;
      } else if (tree.stage == TreeStage.blooming) {
        maxRadius = 120.0;
        yCenter = trunkHeight * 0.7;
      }

      // Each butterfly has random orbit radius
      final orbitRadius = maxRadius * (0.5 + random.nextDouble() * 0.5);

      // Random wave patterns for more organic movement
      final waveFreq = 3.0 + random.nextDouble() * 3.0;
      final waveAmp = 15.0 + random.nextDouble() * 20.0;
      final radiusVariation =
          math.sin(orbitProgress * math.pi * 2.5) * (maxRadius * 0.2);

      // Calculate position with randomized vertical and horizontal wave motion
      final x =
          centerX +
          math.cos(angle) * (orbitRadius + radiusVariation) +
          math.sin(orbitProgress * math.pi * waveFreq) * 10;
      final y =
          groundY -
          yCenter +
          math.sin(angle) * orbitRadius * 0.5 +
          math.sin(orbitProgress * math.pi * waveFreq) * waveAmp;

      _drawMemoryIcon(canvas, Offset(x, y), memory.emotion);
    } else if (memory.emotion == MemoryEmotion.peaceful) {
      final random = math.Random(index + 200);

      // Adjusted spacing to keep rabbits closer together
      final spacing = size.width * 0.08; // Reduced from 0.15 to 0.05
      final baseX = centerX - (spacing * (total / 2)) + (spacing * index);

      // Reduced random offset to keep rabbits within bounds
      final randomOffsetX =
          (random.nextDouble() - 0.5) * 20; // Reduced from 50 to 20

      // Ensure x position stays within canvas bounds
      final iconSize = 15.0;
      final x = math.max(
        iconSize,
        math.min(size.width - iconSize, baseX + randomOffsetX),
      );

      // Jumping animation
      final jumpSpeed = 1 + (random.nextDouble() * 5);
      final jumpProgress = (elapsedTime * jumpSpeed + (index * 0.3)) % 1.0;
      final jumpHeight = math.sin(jumpProgress * math.pi) * 10.0;

      final y = groundY - jumpHeight - 10;

      _drawMemoryIcon(canvas, Offset(x, y), memory.emotion);
    } else if (memory.emotion == MemoryEmotion.love) {
      final random = math.Random(index + 100);
      double yCenter;
      if (tree.stage == TreeStage.seedling) {
        yCenter = trunkHeight * 0.7;
      } else if (tree.stage == TreeStage.growing) {
        yCenter = trunkHeight * 0.8;
      } else {
        yCenter = trunkHeight * 0.9;
      }
      final originX = centerX;
      final originY = groundY - yCenter;
      final cycleDuration = 3.0 + random.nextDouble() * 2.0;
      final lifeProgress =
          (elapsedTime / cycleDuration + (index / total)) % 1.0;
      final time = lifeProgress * 1.5;
      final angle = random.nextDouble() * math.pi * 2;
      double maxSpeed = 160.0;
      if (tree.stage == TreeStage.seedling) {
        maxSpeed = 80.0;
      } else if (tree.stage == TreeStage.growing) {
        maxSpeed = 120.0;
      }

      final initialSpeed = maxSpeed * (0.2 + random.nextDouble() * 0.8);
      final vx = math.cos(angle) * initialSpeed;
      final vy = math.sin(angle) * initialSpeed;
      final gravity =
          160.0; // You can change this value to make it fall faster or slower

      final x = originX + vx * time;
      final y = originY + vy * time + 0.5 * gravity * time * time;

      _drawMemoryIcon(canvas, Offset(x, y), memory.emotion);
    }
  }

  void _drawMemoryIcon(Canvas canvas, Offset position, MemoryEmotion emotion) {
    final iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(position.dx, position.dy);
    final scale = 1.0 + (math.sin(elapsedTime * math.pi * 2) * 0.1);
    canvas.scale(scale);
    switch (emotion) {
      case MemoryEmotion.happy:
        // Realistic pink flower with 5 petals
        paint.color = const Color(0xFFFF69B4); // Hot pink

        // Draw 5 petals
        for (int i = 0; i < 5; i++) {
          canvas.save();
          canvas.rotate(i * math.pi * 2 / 5);

          // Simple petal shape
          final petalPath = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(
              iconSize * 0.2,
              -iconSize * 0.25,
              0,
              -iconSize * 0.45,
            )
            ..quadraticBezierTo(
              -iconSize * 0.2,
              -iconSize * 0.25,
              0,
              0,
            );

          // Gradient effect - lighter at edges
          paint.color = Color.lerp(
            const Color(0xFFFFB6C1), // Light pink
            const Color(0xFFFF69B4), // Hot pink
            (i % 2 == 0) ? 0.7 : 1.0,
          )!;
          canvas.drawPath(petalPath, paint);
          canvas.restore();
        }

        // Simple yellow center
        paint.color = const Color(0xFFFFD700);
        canvas.drawCircle(Offset.zero, iconSize * 0.15, paint);

        // Center detail dots
        paint.color = const Color(0xFFFFA500);
        canvas.drawCircle(Offset.zero, iconSize * 0.08, paint);
        break;
      case MemoryEmotion.love:
        final heartBeat = 1.0 + math.sin(elapsedTime * math.pi * 4) * 0.15;
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
        paint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.8);
        final sparkleAngle = elapsedTime * math.pi * 4;
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
        final flutter = math.sin(elapsedTime * math.pi * 6) * 0.3;
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
        paint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.4);
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
        // 🐰 Simple White Standing Rabbit

        // Gentle breathing animation
        final breathe = 1.0 + math.sin(elapsedTime * math.pi * 1.5) * 0.05;
        canvas.scale(breathe);

        // BIG ROUND TUMMY (bottom)
        paint.color = Colors.white;
        canvas.drawCircle(
          Offset(0, iconSize * 0.2),
          iconSize * 0.4,
          paint,
        );

        // HEAD (smaller circle on top)
        canvas.drawCircle(
          Offset(0, -iconSize * 0.3),
          iconSize * 0.28,
          paint,
        );

        // LONG EARS (simple ovals)
        final earTwitch = math.sin(elapsedTime * math.pi * 3) * 0.1;

        // Left ear
        canvas.save();
        canvas.translate(-iconSize * 0.15, -iconSize * 0.5);
        canvas.rotate(-0.2 + earTwitch);

        // Outer ear (white)
        paint.color = Colors.white;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: iconSize * 0.18,
            height: iconSize * 0.4,
          ),
          paint,
        );

        // Inner ear (pink)
        paint.color = const Color(0xFFFFB6C1);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, iconSize * 0.05),
            width: iconSize * 0.1,
            height: iconSize * 0.28,
          ),
          paint,
        );
        canvas.restore();

        // Right ear
        canvas.save();
        canvas.translate(iconSize * 0.15, -iconSize * 0.5);
        canvas.rotate(0.2 - earTwitch);

        // Outer ear (white)
        paint.color = Colors.white;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: iconSize * 0.18,
            height: iconSize * 0.4,
          ),
          paint,
        );

        // Inner ear (pink)
        paint.color = const Color(0xFFFFB6C1);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, iconSize * 0.05),
            width: iconSize * 0.1,
            height: iconSize * 0.28,
          ),
          paint,
        );
        canvas.restore();

        // Add outline to make it visible
        paint.color = Colors.blueGrey;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;

        // Outline head
        canvas.drawCircle(
          Offset(0, -iconSize * 0.3),
          iconSize * 0.28,
          paint,
        );

        // Outline tummy
        canvas.drawCircle(
          Offset(0, iconSize * 0.2),
          iconSize * 0.4,
          paint,
        );

        paint.style = PaintingStyle.fill;

        // EYES (two black dots)
        paint.color = Colors.black;
        canvas.drawCircle(
          Offset(-iconSize * 0.1, -iconSize * 0.32),
          iconSize * 0.05,
          paint,
        );
        canvas.drawCircle(
          Offset(iconSize * 0.1, -iconSize * 0.32),
          iconSize * 0.05,
          paint,
        );

        // NOSE (pink dot with twitch)
        final noseTwitch = math.sin(elapsedTime * math.pi * 4) * 0.02;
        paint.color = const Color(0xFFFFB6C1);
        canvas.drawCircle(
          Offset(noseTwitch, -iconSize * 0.22),
          iconSize * 0.05,
          paint,
        );

        // SIMPLE MOUTH (Y shape)
        paint.color = Colors.black;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        paint.strokeCap = StrokeCap.round;

        // Mouth lines
        canvas.drawLine(
          Offset(0, -iconSize * 0.22),
          Offset(0, -iconSize * 0.16),
          paint,
        );
        canvas.drawLine(
          Offset(0, -iconSize * 0.16),
          Offset(-iconSize * 0.08, -iconSize * 0.12),
          paint,
        );
        canvas.drawLine(
          Offset(0, -iconSize * 0.16),
          Offset(iconSize * 0.08, -iconSize * 0.12),
          paint,
        );

        paint.style = PaintingStyle.fill;

        // SMALL PAWS (on tummy sides)
        paint.color = Colors.white;
        canvas.drawCircle(
          Offset(-iconSize * 0.35, iconSize * 0.15),
          iconSize * 0.12,
          paint,
        );
        canvas.drawCircle(
          Offset(iconSize * 0.35, iconSize * 0.15),
          iconSize * 0.12,
          paint,
        );

        // Paw outlines
        paint.color = const Color(0xFFE0E0E0);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        canvas.drawCircle(
          Offset(-iconSize * 0.35, iconSize * 0.15),
          iconSize * 0.12,
          paint,
        );
        canvas.drawCircle(
          Offset(iconSize * 0.35, iconSize * 0.15),
          iconSize * 0.12,
          paint,
        );
        paint.style = PaintingStyle.fill;

        // BIG FEET (bottom ovals)
        paint.color = Colors.white;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-iconSize * 0.15, iconSize * 0.52),
            width: iconSize * 0.22,
            height: iconSize * 0.12,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(iconSize * 0.15, iconSize * 0.52),
            width: iconSize * 0.22,
            height: iconSize * 0.12,
          ),
          paint,
        );

        // Feet outlines
        paint.color = const Color(0xFFE0E0E0);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-iconSize * 0.15, iconSize * 0.52),
            width: iconSize * 0.22,
            height: iconSize * 0.12,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(iconSize * 0.15, iconSize * 0.52),
            width: iconSize * 0.22,
            height: iconSize * 0.12,
          ),
          paint,
        );
        paint.style = PaintingStyle.fill;

        break;
      case MemoryEmotion.excited:
      case MemoryEmotion.joyful:
      case MemoryEmotion.grateful:
      case MemoryEmotion.sad:
      case MemoryEmotion.awful:
        break;
    }
    canvas.restore();
  }

  //</editor-fold>
}
