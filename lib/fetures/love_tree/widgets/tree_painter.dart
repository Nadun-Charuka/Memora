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
    final groundY = size.height * 0.80;

    // Draw sky gradient background
    _drawSky(canvas, size);

    // Scale everything x larger for a zoomed-in feel
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

  // Draw floating clouds with varied movement
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
      // {'y': 0.5, 'length': 35.0, 'angle': -0.7},
      // {'y': 0.52, 'length': 35.0, 'angle': 0.7},
      {'y': 0.6, 'length': 33.0, 'angle': -0.65},
      {'y': 0.62, 'length': 33.0, 'angle': 0.65},
      // {'y': 0.7, 'length': 28.0, 'angle': -0.6},
      // {'y': 0.72, 'length': 28.0, 'angle': 0.6},
      {'y': 0.92, 'length': 18.0, 'angle': 0.1},
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
      // {'y': 0.4, 'length': 55.0, 'angle': -0.65},
      // {'y': 0.42, 'length': 55.0, 'angle': 0.65},
      {'y': 0.5, 'length': 60.0, 'angle': -0.6},
      {'y': 0.52, 'length': 60.0, 'angle': 0.6},
      // {'y': 0.6, 'length': 50.0, 'angle': -0.55},
      // {'y': 0.62, 'length': 50.0, 'angle': 0.55},
      {'y': 0.7, 'length': 45.0, 'angle': -0.5},
      {'y': 0.72, 'length': 45.0, 'angle': 0.5},
      {'y': 0.92, 'length': 35.0, 'angle': 0.1},
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
      {'y': 0.92, 'length': 40.0, 'angle': 0.1},
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
  }

  // Draw ground with realistic grass
  void _drawGround(Canvas canvas, Size size, double groundY) {
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

  // Draw flying bird across the sky with varied paths
  void _drawFlyingBird(Canvas canvas, Size size, int index, int total) {
    // Speed and position logic remain the same
    final birdSpeed = 0.4 + (index * 0.2); // 🚀
    final flightProgress =
        (animation.value * birdSpeed + (index / total)) % 1.0;
    final x = size.width * flightProgress;

    final pathVariation = (index % 3) * 2.0;
    final y =
        60.0 +
        (index * 35) +
        math.sin(flightProgress * math.pi * 4 + pathVariation) * 20 +
        math.sin(animation.value * math.pi * 2 + index) * 8;

    final baseSize = 25.0; // Slightly larger base size for more detail
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(x, y);

    // Apply a subtle tilt for a more dynamic flight
    final tiltAngle = math.sin(animation.value * math.pi * 2 + index) * 0.1;
    canvas.rotate(tiltAngle);

    // Wing flapping animation
    final wingFlap =
        math.sin(animation.value * math.pi * 12 + index * 0.5) *
        0.6; // Increased flap amplitude
    final bodyScale =
        1.0 + wingFlap.abs() * 0.08; // Subtle vertical body compression
    canvas.scale(bodyScale, 1.0); // Apply body scale

    // --- BIRD BODY (more detailed shape with gradient) ---
    paint.shader =
        LinearGradient(
          colors: [
            const Color(0xFFE8900C), // Darker orange-gold
            const Color(0xFFFFCC00), // Brighter yellow-gold
          ],
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
      ) // Back
      ..quadraticBezierTo(
        -baseSize * 0.55,
        baseSize * 0.2,
        -baseSize * 0.3,
        baseSize * 0.25,
      ) // Belly
      ..quadraticBezierTo(
        baseSize * 0.2,
        baseSize * 0.25,
        baseSize * 0.4,
        0,
      ) // Front chest
      ..quadraticBezierTo(
        baseSize * 0.2,
        -baseSize * 0.25,
        -baseSize * 0.3,
        0,
      ) // Top back
      ..close();
    canvas.drawPath(bodyPath, paint);
    paint.shader = null; // Clear shader for other parts

    // --- HEAD ---
    paint.color = const Color(0xFFFFCC00); // Brighter yellow for head
    canvas.drawCircle(
      Offset(baseSize * 0.35, -baseSize * 0.05),
      baseSize * 0.2,
      paint,
    );

    // --- EYE (a small dark circle) ---
    paint.color = Colors.black.withOpacity(0.7);
    canvas.drawCircle(
      Offset(baseSize * 0.45, -baseSize * 0.1),
      baseSize * 0.04,
      paint,
    );

    // --- BEAK (sharper, two-tone) ---
    final beakColor = const Color(
      0xFFFFA500,
    ); // A more vivid orange for the beak
    paint.color = beakColor;
    final beakPath = Path()
      ..moveTo(baseSize * 0.48, -baseSize * 0.05)
      ..lineTo(baseSize * 0.65, 0)
      ..lineTo(baseSize * 0.48, baseSize * 0.05)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Add a slight highlight on the beak for depth
    paint.color = Colors.white.withOpacity(0.5);
    final beakHighlightPath = Path()
      ..moveTo(baseSize * 0.5, -baseSize * 0.03)
      ..lineTo(baseSize * 0.6, 0)
      ..lineTo(baseSize * 0.5, baseSize * 0.03)
      ..close();
    canvas.drawPath(beakHighlightPath, paint);

    // --- WINGS with flapping and feather suggestion ---
    // Reset body scale for accurate wing rotation
    canvas.scale(1.0 / bodyScale, 1.0);

    paint.color = const Color(0xFFFF8C00); // Main wing color

    // Wing base angle
    final wingBaseAngle = -0.6; // More angled up initially for flight

    // Left wing
    canvas.save();
    canvas.translate(
      -baseSize * 0.2,
      -baseSize * 0.05,
    ); // Pivot point slightly behind head
    canvas.rotate(wingBaseAngle + wingFlap); // Apply flap here
    _drawWing(canvas, baseSize, paint); // Helper to draw wing shape
    canvas.restore();

    // Right wing
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05); // Same pivot point
    canvas.rotate(
      -(wingBaseAngle + wingFlap),
    ); // Opposite flap for the other wing
    canvas.scale(1, -1); // Flip vertically to match left wing shape on bottom
    _drawWing(canvas, baseSize, paint);
    canvas.restore();

    // Reapply body scale if needed for other elements relative to the body
    canvas.scale(bodyScale, 1.0);

    // --- TAIL FEATHERS (more fanned out) ---
    paint.color = const Color(
      0xFFE8900C,
    ).withOpacity(0.9); // Tail color, slightly darker

    // Center feather
    final tailPathCenter = Path()
      ..moveTo(-baseSize * 0.45, 0)
      ..lineTo(-baseSize * 0.65, -baseSize * 0.1)
      ..lineTo(-baseSize * 0.55, 0)
      ..lineTo(-baseSize * 0.65, baseSize * 0.1)
      ..close();
    canvas.drawPath(tailPathCenter, paint);

    // Side feathers for fanned look
    final tailPaintThin = Paint()
      ..color = const Color(0xFFC77C00)
          .withOpacity(0.8) // Darker for separation
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke; // Draw as outlines

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

    canvas.restore(); // Restore overall canvas state
  }

  // Helper function to draw a single wing for reusability
  void _drawWing(Canvas canvas, double baseSize, Paint paint) {
    // Wing shape using Path
    final wingPath = Path()
      ..moveTo(0, 0) // Pivot point
      ..quadraticBezierTo(
        baseSize * 0.3,
        -baseSize * 0.4,
        baseSize * 0.8,
        -baseSize * 0.3,
      ) // Outer edge curve
      ..quadraticBezierTo(
        baseSize * 0.5,
        -baseSize * 0.1,
        baseSize * 0.4,
        0,
      ) // Inner curve
      ..close();
    canvas.drawPath(wingPath, paint);

    // Simple feather lines
    paint.color = Colors.black.withOpacity(0.2); // Darker lines
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
    paint.style = PaintingStyle.fill; // Reset to fill
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

  // Draw falling raindrop from top to ground
  void _drawFallingRain(Canvas canvas, Size size, int index, int total) {
    final x = (size.width / (total + 1)) * (index + 1);

    // Rain falls from sky to ground
    final fallSpeed = 0.5 + (index * 0.15);
    final fallProgress = (animation.value * fallSpeed) % 1.0;

    // Start from top of sky, end at ground level
    final startY = size.height * 0.1;
    final endY = size.height * 0.85;
    final y = startY + ((endY - startY) * fallProgress);

    final iconSize = 8.0;
    final paint = Paint()..style = PaintingStyle.fill;

    // Add slight horizontal drift
    final drift = math.sin(fallProgress * math.pi * 3) * 10;

    canvas.save();
    canvas.translate(x + drift, y);

    // Raindrop opacity increases as it falls
    final opacity = 0.5 + (fallProgress * 0.4);

    // Raindrop shape
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

    // Shine
    paint.color = Colors.white.withOpacity(0.5 * opacity);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.4),
      iconSize * 0.18,
      paint,
    );

    // Splash effect when near ground
    if (fallProgress > 0.92) {
      final splashProgress = (fallProgress - 0.92) / 0.08;
      final splashSize = splashProgress * iconSize * 1.5;

      paint.color = const Color(
        0xFF4682B4,
      ).withOpacity(0.4 * (1 - splashProgress));

      // Splash circles
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
