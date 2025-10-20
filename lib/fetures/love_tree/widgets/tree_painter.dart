import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/models/tree_model.dart';

class TreePainter extends CustomPainter {
  final LoveTree tree;
  final List<Memory> memories;
  final Animation<double> animation;

  TreePainter({
    required this.tree,
    required this.memories,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.85;

    // Draw sky gradient background
    _drawSky(canvas, size);

    // Scale everything 2x larger for a zoomed-in feel
    canvas.save();
    canvas.translate(centerX, groundY);
    canvas.scale(1.5, 1.5);
    canvas.translate(-centerX, -groundY);

    if (!tree.isPlanted) {
      _drawUnplantedState(canvas, size, centerX, groundY);
      canvas.restore();
      return;
    }

    // Draw based on stage
    switch (tree.stage) {
      case TreeStage.notPlanted:
        _drawUnplantedState(canvas, size, centerX, groundY);
        break;
      case TreeStage.seedling:
        _drawSeedling(canvas, size, centerX, groundY);
        break;
      case TreeStage.growing:
        _drawGrowing(canvas, size, centerX, groundY);
        break;
      case TreeStage.blooming:
        _drawBlooming(canvas, size, centerX, groundY);
        break;
      case TreeStage.mature:
        _drawMature(canvas, size, centerX, groundY);
        break;
    }

    canvas.restore();

    // Draw memories with advanced animations (outside transform)
    if (tree.isPlanted) {
      _drawMemoriesAdvanced(canvas, size, centerX, groundY);
    }
  }

  // Draw beautiful sky gradient
  void _drawSky(Canvas canvas, Size size) {
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

    // Draw clouds
    _drawClouds(canvas, size);
  }

  // Draw floating clouds
  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Animate clouds moving across
    final cloudOffset = (animation.value * 100) % (size.width + 200);

    // Cloud 1
    _drawCloud(canvas, Offset(cloudOffset - 100, 40), cloudPaint);

    // Cloud 2
    _drawCloud(canvas, Offset(cloudOffset + size.width / 2, 80), cloudPaint);

    // Cloud 3
    _drawCloud(canvas, Offset(cloudOffset - 200, 120), cloudPaint);
  }

  void _drawCloud(Canvas canvas, Offset position, Paint paint) {
    canvas.drawCircle(position, 20, paint);
    canvas.drawCircle(position.translate(15, -5), 25, paint);
    canvas.drawCircle(position.translate(30, 0), 20, paint);
    canvas.drawCircle(position.translate(20, 5), 22, paint);
  }

  // Draw unplanted state
  void _drawUnplantedState(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY,
  ) {
    _drawGround(canvas, size, groundY);

    // Draw planting spot with glow
    final glowPaint = Paint()
      ..color = const Color(0xFF6B5345).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(Offset(centerX, groundY + 20), 40, glowPaint);

    final spotPaint = Paint()
      ..color = const Color(0xFF6B5345)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, groundY + 20), 30, spotPaint);

    // Animated waiting indicator
    final scale = 1.0 + math.sin(animation.value * math.pi * 2) * 0.2;
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
  }

  // Draw seedling with subtle sway
  void _drawSeedling(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final stemHeight = tree.height * 2;
    final sway = math.sin(animation.value * math.pi * 2) * 2;

    final stemPaint = Paint()
      ..color = const Color(0xFF4A7C59)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw swaying stem
    canvas.drawLine(
      Offset(centerX, groundY),
      Offset(centerX + sway, groundY - stemHeight),
      stemPaint,
    );

    // Draw animated leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF6B9B78)
      ..style = PaintingStyle.fill;

    final leafSway = math.sin(animation.value * math.pi * 2 + 0.5) * 3;

    // Leaves with gentle movement
    _drawLeaf(
      canvas,
      Offset(centerX - 8 + leafSway, groundY - stemHeight * 0.5),
      8,
      leafPaint,
      -0.4,
    );
    _drawLeaf(
      canvas,
      Offset(centerX - 10 + leafSway, groundY - stemHeight * 0.7),
      7,
      leafPaint,
      -0.5,
    );
    _drawLeaf(
      canvas,
      Offset(centerX + 8 - leafSway, groundY - stemHeight * 0.6),
      8,
      leafPaint,
      0.4,
    );
    _drawLeaf(
      canvas,
      Offset(centerX + 10 - leafSway, groundY - stemHeight * 0.8),
      7,
      leafPaint,
      0.5,
    );
  }

  // Draw growing tree with wind animation
  void _drawGrowing(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5;
    final windSway = math.sin(animation.value * math.pi * 2) * 3;

    // Draw trunk with texture
    _drawTrunkWithTexture(canvas, centerX, groundY, trunkHeight, 8, windSway);

    // Draw branches with leaf clusters
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final branches = [
      {'y': 0.4, 'length': 30.0, 'angle': -0.6},
      {'y': 0.42, 'length': 30.0, 'angle': 0.6},
      {'y': 0.5, 'length': 35.0, 'angle': -0.7},
      {'y': 0.52, 'length': 35.0, 'angle': 0.7},
      {'y': 0.6, 'length': 33.0, 'angle': -0.65},
      {'y': 0.62, 'length': 33.0, 'angle': 0.65},
      {'y': 0.7, 'length': 28.0, 'angle': -0.6},
      {'y': 0.72, 'length': 28.0, 'angle': 0.6},
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      final length = branch['length'] as double;
      final angle = branch['angle'] as double;
      final branchSway = windSway * (1.0 - (branch['y'] as double));

      final startOffset = Offset(centerX + branchSway, y);
      _drawBranch(canvas, startOffset, length, angle, branchPaint);

      final leafEnd = Offset(
        startOffset.dx + length * math.sin(angle),
        startOffset.dy - length * math.cos(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 4, 10);
    }
  }

  // Draw blooming tree
  void _drawBlooming(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height * 1.2;
    final windSway = math.sin(animation.value * math.pi * 2) * 4;

    _drawTrunkWithTexture(canvas, centerX, groundY, trunkHeight, 12, windSway);

    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final branches = [
      {'y': 0.3, 'length': 50.0, 'angle': -0.7},
      {'y': 0.32, 'length': 50.0, 'angle': 0.7},
      {'y': 0.4, 'length': 55.0, 'angle': -0.65},
      {'y': 0.42, 'length': 55.0, 'angle': 0.65},
      {'y': 0.5, 'length': 60.0, 'angle': -0.6},
      {'y': 0.52, 'length': 60.0, 'angle': 0.6},
      {'y': 0.6, 'length': 50.0, 'angle': -0.55},
      {'y': 0.62, 'length': 50.0, 'angle': 0.55},
      {'y': 0.7, 'length': 45.0, 'angle': -0.5},
      {'y': 0.72, 'length': 45.0, 'angle': 0.5},
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      final length = branch['length'] as double;
      final angle = branch['angle'] as double;
      final branchSway = windSway * (1.0 - (branch['y'] as double));

      final startOffset = Offset(centerX + branchSway, y);
      _drawBranch(canvas, startOffset, length, angle, branchPaint);

      final leafEnd = Offset(
        startOffset.dx + length * math.sin(angle),
        startOffset.dy - length * math.cos(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 6, 12);
    }
  }

  // Draw mature tree
  void _drawMature(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height;
    final windSway = math.sin(animation.value * math.pi * 2) * 5;

    _drawTrunkWithTexture(canvas, centerX, groundY, trunkHeight, 15, windSway);

    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final branches = [
      {'y': 0.2, 'length': 70.0, 'angle': -0.9},
      {'y': 0.22, 'length': 70.0, 'angle': 0.9},
      {'y': 0.35, 'length': 80.0, 'angle': -0.7},
      {'y': 0.37, 'length': 80.0, 'angle': 0.7},
      {'y': 0.5, 'length': 85.0, 'angle': -0.6},
      {'y': 0.52, 'length': 85.0, 'angle': 0.6},
      {'y': 0.65, 'length': 75.0, 'angle': -0.5},
      {'y': 0.67, 'length': 75.0, 'angle': 0.5},
      {'y': 0.8, 'length': 60.0, 'angle': -0.4},
      {'y': 0.82, 'length': 60.0, 'angle': 0.4},
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      final length = branch['length'] as double;
      final angle = branch['angle'] as double;
      final branchSway = windSway * (1.0 - (branch['y'] as double));

      final startOffset = Offset(centerX + branchSway, y);
      _drawBranch(canvas, startOffset, length, angle, branchPaint);

      final leafEnd = Offset(
        startOffset.dx + length * math.sin(angle),
        startOffset.dy - length * math.cos(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 8, 14);
    }
  }

  // Draw trunk with bark texture
  void _drawTrunkWithTexture(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // Main trunk with sway
    canvas.drawLine(
      Offset(centerX, groundY),
      Offset(centerX + sway, groundY - height),
      trunkPaint,
    );

    // Bark texture lines
    final texturePaint = Paint()
      ..color = const Color(0xFF4A3018)
      ..strokeWidth = width * 0.15
      ..strokeCap = StrokeCap.round;

    for (double i = 0.1; i < 1.0; i += 0.15) {
      final y = groundY - height * i;
      final xOffset = math.sin(i * 10) * width * 0.3;
      canvas.drawLine(
        Offset(centerX - width / 3 + xOffset, y),
        Offset(centerX + width / 3 + xOffset, y),
        texturePaint,
      );
    }
  }

  // Draw ground with grass
  void _drawGround(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );

    // Animated grass
    final grassPaint = Paint()
      ..color = const Color(0xFF6B9B78)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < size.width; i += 15) {
      final sway = math.sin(animation.value * math.pi * 2 + i * 0.1) * 2;
      canvas.drawLine(
        Offset(i.toDouble(), groundY),
        Offset(i.toDouble() + 3 + sway, groundY - 12),
        grassPaint,
      );
    }
  }

  // Draw branch
  void _drawBranch(
    Canvas canvas,
    Offset start,
    double length,
    double angle,
    Paint paint,
  ) {
    final end = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );
    canvas.drawLine(start, end, paint);
  }

  // Draw leaf
  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(0, -size)
      ..quadraticBezierTo(size * 0.5, -size * 0.5, size * 0.3, 0)
      ..quadraticBezierTo(size * 0.5, size * 0.5, 0, size)
      ..quadraticBezierTo(-size * 0.5, size * 0.5, -size * 0.3, 0)
      ..quadraticBezierTo(-size * 0.5, -size * 0.5, 0, -size);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  // Draw leaf cluster with animation
  void _drawLeafCluster(Canvas canvas, Offset center, int count, double size) {
    final leafPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF6B9B78),
        const Color(0xFF4A7C59),
        animation.value,
      )!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 + animation.value * 0.5;
      final rustleOffset = math.sin(animation.value * math.pi * 2 + i) * 2;
      final offset = Offset(
        center.dx + math.cos(angle) * (size * 0.7 + rustleOffset),
        center.dy + math.sin(angle) * (size * 0.7 + rustleOffset),
      );
      _drawLeaf(canvas, offset, size, leafPaint, angle);
    }
  }

  // Advanced memory drawing with realistic positioning
  void _drawMemoriesAdvanced(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY,
  ) {
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

    // Draw birds flying in the sky
    for (int i = 0; i < birdMemories.length; i++) {
      _drawFlyingBird(canvas, size, i, birdMemories.length);
    }

    // Draw stars twinkling in the sky
    for (int i = 0; i < starMemories.length; i++) {
      _drawTwinklingStar(canvas, size, i, starMemories.length);
    }

    // Draw raindrops falling from top
    for (int i = 0; i < rainMemories.length; i++) {
      _drawFallingRain(canvas, size, i, rainMemories.length);
    }

    // Draw fruits hanging on branches
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

    // Draw other memories on tree (flowers, hearts, butterflies, leaves)
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

  // Draw flying bird across the sky
  void _drawFlyingBird(Canvas canvas, Size size, int index, int total) {
    final birdSpeed = 0.15 + (index * 0.05);
    final flightPath = (animation.value * birdSpeed) % 1.2 - 0.1;
    final x = size.width * flightPath;
    final y =
        60.0 +
        index * 40 +
        math.sin(animation.value * math.pi * 4 + index) * 15;

    final iconSize = 20.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x, y);

    // Wing flapping animation
    final wingFlap = math.sin(animation.value * math.pi * 8) * 0.3;
    final scale = 1.0 + wingFlap * 0.2;
    canvas.scale(scale, 1.0);

    // Bird silhouette (orange/golden bird)
    paint.color = const Color(0xFFFF8C00);

    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: iconSize * 0.6,
        height: iconSize * 0.4,
      ),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(iconSize * 0.35, 0), iconSize * 0.25, paint);

    // Beak
    paint.color = const Color(0xFFFFD700);
    final beakPath = Path()
      ..moveTo(iconSize * 0.5, -2)
      ..lineTo(iconSize * 0.65, 0)
      ..lineTo(iconSize * 0.5, 2)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Wings with flapping
    paint.color = const Color(0xFFFF8C00);
    final wingAngle = -0.8 + wingFlap;

    // Left wing
    canvas.save();
    canvas.rotate(wingAngle);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-iconSize * 0.4, 0),
        width: iconSize * 0.6,
        height: iconSize * 0.3,
      ),
      paint,
    );
    canvas.restore();

    // Right wing
    canvas.save();
    canvas.rotate(-wingAngle);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-iconSize * 0.4, 0),
        width: iconSize * 0.6,
        height: iconSize * 0.3,
      ),
      paint,
    );
    canvas.restore();

    canvas.restore();
  }

  // Draw twinkling star in sky
  void _drawTwinklingStar(Canvas canvas, Size size, int index, int total) {
    final x = (size.width / (total + 1)) * (index + 1);
    final y = 40.0 + (index % 3) * 30;

    final iconSize = 12.0;
    final twinkle =
        (math.sin(animation.value * math.pi * 4 + index * 2) + 1) / 2;
    final scale = 0.7 + twinkle * 0.6;

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.8 + twinkle * 0.2)
      ..style = PaintingStyle.fill;

    // Star shape
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

    // Star glow
    paint
      ..color = const Color(0xFFFFD700).withOpacity(0.3 * twinkle)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(starPath, paint);

    canvas.restore();
  }

  // Draw falling raindrop from top
  void _drawFallingRain(Canvas canvas, Size size, int index, int total) {
    final x = (size.width / (total + 1)) * (index + 1);
    final fallSpeed = 0.3 + (index * 0.1);
    final fallProgress = (animation.value * fallSpeed) % 1.0;
    final y = size.height * 0.15 + (size.height * 0.3 * fallProgress);

    final iconSize = 6.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x, y);

    // Raindrop shape
    paint.color = const Color(0xFF4682B4).withOpacity(0.7);
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

    // Shine
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.3),
      iconSize * 0.15,
      paint,
    );

    canvas.restore();
  }

  // Draw hanging fruit on tree branches
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

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -iconSize * 0.5),
      Offset(0, -iconSize * 0.8),
      stemPaint,
    );

    // Apple/fruit
    final fruitPaint = Paint()
      ..color = const Color(0xFFFF6347)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, iconSize * 0.45, fruitPaint);

    // Shine
    fruitPaint.color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.15),
      iconSize * 0.15,
      fruitPaint,
    );

    // Leaf on top
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

  // Draw other memories on tree (flowers, hearts, butterflies, leaves)
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

  // Draw memory icon
  void _drawMemoryIcon(Canvas canvas, Offset position, MemoryEmotion emotion) {
    final iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    // Pulsing animation
    final scale = 1.0 + (math.sin(animation.value * math.pi * 2) * 0.1);
    canvas.scale(scale);

    switch (emotion) {
      case MemoryEmotion.happy:
        // Blooming flower
        paint.color = const Color(0xFFFFB6C1);
        final petalRotation = animation.value * 0.2;

        for (int i = 0; i < 6; i++) {
          canvas.save();
          canvas.rotate((i * math.pi * 2 / 6) + petalRotation);

          // Petal
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

        // Center
        paint.color = const Color(0xFFFFD700);
        canvas.drawCircle(Offset.zero, iconSize * 0.2, paint);

        // Pollen dots
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
        // Beating heart
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

        // Sparkles around heart
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
        // Fluttering butterfly
        final flutter = math.sin(animation.value * math.pi * 6) * 0.3;

        paint.color = const Color(0xFFBA55D3);

        // Left wing
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

        // Right wing
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

        // Wing patterns
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

        // Body
        paint.color = const Color(0xFF000000);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, 0),
            width: iconSize * 0.15,
            height: iconSize * 0.6,
          ),
          paint,
        );

        // Antennae
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
        // Gently swaying leaf
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
          ..quadraticBezierTo(
            iconSize * 0.3,
            iconSize * 0.3,
            0,
            iconSize * 0.5,
          )
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

        // Leaf veins
        paint.color = const Color(0xFF228B22);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawLine(
          Offset(0, -iconSize * 0.5),
          Offset(0, iconSize * 0.5),
          paint,
        );

        // Side veins
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
        // This case handled separately in flying birds
        break;

      case MemoryEmotion.joyful:
        // This case handled separately in hanging fruits
        break;

      case MemoryEmotion.grateful:
        // This case handled separately in twinkling stars
        break;

      case MemoryEmotion.sad:
        // This case handled separately in falling rain
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.tree != tree ||
        oldDelegate.memories.length != memories.length ||
        oldDelegate.animation.value != animation.value;
  }
}
