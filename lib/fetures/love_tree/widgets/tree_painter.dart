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

    // Draw memories as decorations on the tree
    if (tree.isPlanted) {
      _drawMemories(canvas, size, centerX, groundY);
    }

    canvas.restore();
  }

  // Draw unplanted state (just ground and marker)
  void _drawUnplantedState(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY,
  ) {
    // Draw ground
    final groundPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );

    // Draw planting spot
    final spotPaint = Paint()
      ..color = const Color(0xFF6B5345)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, groundY + 20),
      30,
      spotPaint,
    );

    // Draw waiting indicator
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🌱',
        style: TextStyle(fontSize: 40),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, groundY - 10),
    );
  }

  // Draw seedling stage (small sprout)
  void _drawSeedling(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final stemHeight = tree.height * 2;
    final stemPaint = Paint()
      ..color = const Color(0xFF4A7C59)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw stem
    canvas.drawLine(
      Offset(centerX, groundY),
      Offset(centerX, groundY - stemHeight),
      stemPaint,
    );

    // Draw 4 small leaves - 2 on each side
    final leafPaint = Paint()
      ..color = const Color(0xFF6B9B78)
      ..style = PaintingStyle.fill;

    // LEFT SIDE
    _drawLeaf(
      canvas,
      Offset(centerX - 8, groundY - stemHeight * 0.5),
      8,
      leafPaint,
      -0.4,
    );
    _drawLeaf(
      canvas,
      Offset(centerX - 10, groundY - stemHeight * 0.7),
      7,
      leafPaint,
      -0.5,
    );

    // RIGHT SIDE
    _drawLeaf(
      canvas,
      Offset(centerX + 8, groundY - stemHeight * 0.6),
      8,
      leafPaint,
      0.4,
    );
    _drawLeaf(
      canvas,
      Offset(centerX + 10, groundY - stemHeight * 0.8),
      7,
      leafPaint,
      0.5,
    );
  }

  // Draw growing stage (young tree with balanced branches)
  void _drawGrowing(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5;
    final trunkPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Draw trunk
    canvas.drawLine(
      Offset(centerX, groundY),
      Offset(centerX, groundY - trunkHeight),
      trunkPaint,
    );

    // Draw balanced branches - BOTH SIDES
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final branchStartY = groundY - trunkHeight * 0.4;

    // 6 branches - alternating left and right
    final branches = [
      {'y': 0.0, 'length': 25.0, 'angle': -0.6}, // LEFT
      {'y': 5.0, 'length': 25.0, 'angle': 0.6}, // RIGHT
      {'y': 15.0, 'length': 30.0, 'angle': -0.7}, // LEFT
      {'y': 20.0, 'length': 30.0, 'angle': 0.7}, // RIGHT
      {'y': 30.0, 'length': 28.0, 'angle': -0.65}, // LEFT
      {'y': 35.0, 'length': 28.0, 'angle': 0.65}, // RIGHT
    ];

    for (var branch in branches) {
      final y = branchStartY - (branch['y'] as double);
      final length = branch['length'] as double;
      final angle = branch['angle'] as double;
      final startOffset = Offset(centerX, y);

      _drawBranch(canvas, startOffset, length, angle, branchPaint);

      // Add leaves at the end of the branch
      // CORRECTED CALCULATION HERE
      final leafEnd = Offset(
        startOffset.dx + length * math.sin(angle),
        startOffset.dy - length * math.cos(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 3, 10);
    }
  }

  // Draw blooming stage (fuller tree with balanced branches)
  void _drawBlooming(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height * 1.2;
    final trunkPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw trunk
    canvas.drawLine(
      Offset(centerX, groundY),
      Offset(centerX, groundY - trunkHeight),
      trunkPaint,
    );

    // Draw main branches - PERFECTLY BALANCED BOTH SIDES
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final branches = [
      {'y': 0.3, 'length': 50.0, 'angle': -0.7}, // LEFT
      {'y': 0.32, 'length': 50.0, 'angle': 0.7}, // RIGHT
      {'y': 0.4, 'length': 55.0, 'angle': -0.65}, // LEFT
      {'y': 0.42, 'length': 55.0, 'angle': 0.65}, // RIGHT
      {'y': 0.5, 'length': 60.0, 'angle': -0.6}, // LEFT
      {'y': 0.52, 'length': 60.0, 'angle': 0.6}, // RIGHT
      {'y': 0.6, 'length': 50.0, 'angle': -0.55}, // LEFT
      {'y': 0.62, 'length': 50.0, 'angle': 0.55}, // RIGHT
      {'y': 0.7, 'length': 45.0, 'angle': -0.5}, // LEFT
      {'y': 0.72, 'length': 45.0, 'angle': 0.5}, // RIGHT
      {'y': 0.8, 'length': 40.0, 'angle': -0.5}, // LEFT
      {'y': 0.82, 'length': 40.0, 'angle': 0.5}, // RIGHT
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      final length = branch['length'] as double;
      final angle = branch['angle'] as double;
      final startOffset = Offset(centerX, y);

      _drawBranch(canvas, startOffset, length, angle, branchPaint);

      // Add leaf clusters at the end of the branch
      // CORRECTED CALCULATION HERE
      final leafEnd = Offset(
        startOffset.dx + length * math.sin(angle),
        startOffset.dy - length * math.cos(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 6, 12);
    }
  }

  // Draw mature stage (full balanced tree)
  void _drawMature(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height;
    final trunkPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    // Draw thick trunk
    canvas.drawLine(
      Offset(centerX, groundY),
      Offset(centerX, groundY - trunkHeight),
      trunkPaint,
    );

    // Draw extensive balanced branch system - BOTH SIDES
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Create perfectly balanced branches - alternating left/right
    final branches = [
      {'y': 0.2, 'length': 70.0, 'angle': -0.8}, // LEFT
      {'y': 0.22, 'length': 70.0, 'angle': 0.8}, // RIGHT
      // {'y': 0.25, 'length': 75.0, 'angle': -0.75}, // LEFT
      // {'y': 0.27, 'length': 75.0, 'angle': 0.75}, // RIGHT
      {'y': 0.35, 'length': 80.0, 'angle': -0.7}, // LEFT
      {'y': 0.37, 'length': 80.0, 'angle': 0.7}, // RIGHT
      // {'y': 0.4, 'length': 85.0, 'angle': -0.65}, // LEFT
      // {'y': 0.42, 'length': 85.0, 'angle': 0.65}, // RIGHT
      {'y': 0.5, 'length': 85.0, 'angle': -0.6}, // LEFT
      {'y': 0.52, 'length': 85.0, 'angle': 0.6}, // RIGHT
      // {'y': 0.55, 'length': 80.0, 'angle': -0.55}, // LEFT
      // {'y': 0.57, 'length': 80.0, 'angle': 0.55}, // RIGHT
      {'y': 0.65, 'length': 75.0, 'angle': -0.5}, // LEFT
      {'y': 0.67, 'length': 75.0, 'angle': 0.5}, // RIGHT
      // {'y': 0.7, 'length': 70.0, 'angle': -0.45}, // LEFT
      // {'y': 0.72, 'length': 70.0, 'angle': 0.45}, // RIGHT
      {'y': 0.8, 'length': 60.0, 'angle': -0.4}, // LEFT
      {'y': 0.82, 'length': 60.0, 'angle': 0.4}, // RIGHT
      // {'y': 0.85, 'length': 55.0, 'angle': -0.35}, // LEFT
      // {'y': 0.87, 'length': 55.0, 'angle': 0.35}, // RIGHT
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      final length = branch['length'] as double;
      final angle = branch['angle'] as double;
      final startOffset = Offset(centerX, y);

      _drawBranch(canvas, startOffset, length, angle, branchPaint);

      // Add leaf clusters at the end of the branch
      // CORRECTED CALCULATION HERE
      final leafEnd = Offset(
        startOffset.dx + length * math.sin(angle),
        startOffset.dy - length * math.cos(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 8, 14);
    }
  }

  // Helper: Draw ground
  void _drawGround(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );

    // Draw grass
    final grassPaint = Paint()
      ..color = const Color(0xFF6B9B78)
      ..strokeWidth = 2;

    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), groundY),
        Offset(i.toDouble() + 5, groundY - 10),
        grassPaint,
      );
    }
  }

  // Helper: Draw a branch
  void _drawBranch(
    Canvas canvas,
    Offset start,
    double length,
    double angle,
    Paint paint,
  ) {
    // The corrected logic is here!
    final end = Offset(
      start.dx +
          length * math.sin(angle), // Use sin for horizontal (left/right)
      start.dy - length * math.cos(angle), // Use cos for vertical (up/down)
    );
    canvas.drawLine(start, end, paint);
  }

  // Helper: Draw leaf
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

  // Helper: Draw leaf cluster
  void _drawLeafCluster(Canvas canvas, Offset center, int count, double size) {
    final leafPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF6B9B78),
        const Color(0xFF4A7C59),
        animation.value,
      )!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2;
      final offset = Offset(
        center.dx + math.cos(angle) * size * 0.7,
        center.dy + math.sin(angle) * size * 0.7,
      );
      _drawLeaf(canvas, offset, size, leafPaint, angle);
    }
  }

  // Draw memories as decorations with better distribution
  void _drawMemories(Canvas canvas, Size size, double centerX, double groundY) {
    if (memories.isEmpty) return;

    final trunkHeight =
        tree.height *
        (tree.stage == TreeStage.seedling
            ? 2
            : tree.stage == TreeStage.growing
            ? 1.5
            : 1.2);

    // Better memory distribution - spiral pattern
    for (int i = 0; i < memories.length; i++) {
      final memory = memories[i];

      // Spiral distribution for better spread
      final spiralTurns = (i / memories.length) * 3; // 3 full spirals
      final angle = spiralTurns * math.pi * 2;
      final radiusProgress = (i / memories.length); // 0 to 1

      // Position based on tree stage
      double maxRadius;
      double yOffset;

      switch (tree.stage) {
        case TreeStage.seedling:
          maxRadius = 20;
          yOffset = trunkHeight * 0.5;
          break;
        case TreeStage.growing:
          maxRadius = 40;
          yOffset = trunkHeight * 0.6;
          break;
        case TreeStage.blooming:
          maxRadius = 70;
          yOffset = trunkHeight * 0.7;
          break;
        case TreeStage.mature:
          maxRadius = 100;
          yOffset = trunkHeight * 0.6;
          break;
        case TreeStage.notPlanted:
          continue;
      }

      // Spiral from center outward
      final radius = 10 + (radiusProgress * maxRadius);
      final x = centerX + math.cos(angle) * radius;

      // Add vertical variation for more natural look
      final verticalVariation = math.sin(angle * 2) * 15;
      final y =
          groundY -
          yOffset +
          math.sin(angle) * radius * 0.3 +
          verticalVariation;

      // Draw memory icon based on emotion
      _drawMemoryIcon(canvas, Offset(x, y), memory.emotion, size, groundY);
    }
  }

  // Draw memory icon with special positioning for eagles and raindrops
  void _drawMemoryIcon(
    Canvas canvas,
    Offset position,
    MemoryEmotion emotion,
    Size size,
    double groundY,
  ) {
    final iconSize = 20.0;
    final paint = Paint()..style = PaintingStyle.fill;

    // Special positioning for eagles (fly below tree) and raindrops (float above)
    Offset finalPosition = position;

    if (emotion == MemoryEmotion.excited) {
      // Eagles fly below the tree
      finalPosition = Offset(position.dx, groundY - 30);
    } else if (emotion == MemoryEmotion.sad) {
      // Raindrops float above the tree
      finalPosition = Offset(position.dx, position.dy - 80);
    }

    canvas.save();
    canvas.translate(finalPosition.dx, finalPosition.dy);

    // Pulsing animation
    final scale = 1.0 + (math.sin(animation.value * math.pi * 2) * 0.1);
    canvas.scale(scale);

    switch (emotion) {
      case MemoryEmotion.happy:
        // Draw flower 🌸
        paint.color = const Color(0xFFFFB6C1);
        for (int i = 0; i < 5; i++) {
          canvas.save();
          canvas.rotate((i * math.pi * 2 / 5));
          canvas.drawCircle(Offset(0, -iconSize * 0.4), iconSize * 0.3, paint);
          canvas.restore();
        }
        paint.color = const Color(0xFFFFD700);
        canvas.drawCircle(Offset.zero, iconSize * 0.2, paint);
        break;

      case MemoryEmotion.excited:
        // Draw flying eagle - yellow/golden color mix

        // Body (golden brown)
        paint.color = const Color(0xFFDAA520); // Golden rod
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: iconSize * 0.5,
            height: iconSize * 0.8,
          ),
          paint,
        );

        // Head (lighter golden)
        paint.color = const Color(0xFFFFA500); // Orange gold
        canvas.drawCircle(Offset(0, -iconSize * 0.45), iconSize * 0.3, paint);

        // Sharp beak (dark yellow)
        paint.color = const Color(0xFFFFD700); // Gold
        final beakPath = Path()
          ..moveTo(iconSize * 0.15, -iconSize * 0.45)
          ..lineTo(iconSize * 0.45, -iconSize * 0.4)
          ..lineTo(iconSize * 0.15, -iconSize * 0.35)
          ..close();
        canvas.drawPath(beakPath, paint);

        // Large spread wings (golden brown with details)
        paint.color = const Color(0xFFB8860B); // Dark golden rod
        paint.style = PaintingStyle.fill;

        // Left wing - large and majestic
        final leftWing = Path()
          ..moveTo(-iconSize * 0.2, 0)
          ..quadraticBezierTo(
            -iconSize * 0.5,
            -iconSize * 0.4,
            -iconSize * 0.9,
            -iconSize * 0.2,
          )
          ..quadraticBezierTo(
            -iconSize * 0.6,
            -iconSize * 0.05,
            -iconSize * 0.2,
            0.1,
          );
        canvas.drawPath(leftWing, paint);

        // Right wing - large and majestic
        final rightWing = Path()
          ..moveTo(iconSize * 0.2, 0)
          ..quadraticBezierTo(
            iconSize * 0.5,
            -iconSize * 0.4,
            iconSize * 0.9,
            -iconSize * 0.2,
          )
          ..quadraticBezierTo(
            iconSize * 0.6,
            -iconSize * 0.05,
            iconSize * 0.2,
            0.1,
          );
        canvas.drawPath(rightWing, paint);

        // Wing feather details
        paint.color = const Color(0xFFDAA520);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;

        // Left wing feathers
        canvas.drawLine(
          Offset(-iconSize * 0.3, -iconSize * 0.05),
          Offset(-iconSize * 0.7, -iconSize * 0.25),
          paint,
        );
        canvas.drawLine(
          Offset(-iconSize * 0.4, -iconSize * 0.1),
          Offset(-iconSize * 0.8, -iconSize * 0.2),
          paint,
        );

        // Right wing feathers
        canvas.drawLine(
          Offset(iconSize * 0.3, -iconSize * 0.05),
          Offset(iconSize * 0.7, -iconSize * 0.25),
          paint,
        );
        canvas.drawLine(
          Offset(iconSize * 0.4, -iconSize * 0.1),
          Offset(iconSize * 0.8, -iconSize * 0.2),
          paint,
        );

        // Tail feathers
        paint.style = PaintingStyle.fill;
        paint.color = const Color(0xFFB8860B);
        final tailPath = Path()
          ..moveTo(-iconSize * 0.15, iconSize * 0.4)
          ..lineTo(0, iconSize * 0.6)
          ..lineTo(iconSize * 0.15, iconSize * 0.4)
          ..close();
        canvas.drawPath(tailPath, paint);

        paint.style = PaintingStyle.fill;
        break;

      case MemoryEmotion.joyful:
        // Draw fruit 🍎
        paint.color = const Color(0xFFFF6347);
        canvas.drawCircle(Offset.zero, iconSize * 0.4, paint);
        paint.color = const Color(0xFF228B22);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, -iconSize * 0.5),
            width: iconSize * 0.3,
            height: iconSize * 0.2,
          ),
          paint,
        );
        break;

      case MemoryEmotion.grateful:
        // Draw star ⭐
        paint.color = const Color(0xFFFFD700);
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
        break;

      case MemoryEmotion.love:
        // Draw heart ❤️
        paint.color = const Color(0xFFFF1493);
        final heartPath = Path();
        heartPath.moveTo(0, iconSize * 0.3);
        heartPath.cubicTo(
          -iconSize * 0.5,
          -iconSize * 0.1,
          -iconSize * 0.5,
          -iconSize * 0.5,
          0,
          -iconSize * 0.2,
        );
        heartPath.cubicTo(
          iconSize * 0.5,
          -iconSize * 0.5,
          iconSize * 0.5,
          -iconSize * 0.1,
          0,
          iconSize * 0.3,
        );
        canvas.drawPath(heartPath, paint);
        break;

      case MemoryEmotion.sad:
        // Draw floating raindrop 💧 (with gentle sway)
        final sway = math.sin(animation.value * math.pi * 2) * 3;
        canvas.translate(sway, 0);

        paint.color = const Color(0xFF4682B4);
        final dropPath = Path();
        dropPath.moveTo(0, -iconSize * 0.5);
        dropPath.quadraticBezierTo(
          iconSize * 0.35,
          -iconSize * 0.1,
          iconSize * 0.2,
          iconSize * 0.3,
        );
        dropPath.quadraticBezierTo(
          iconSize * 0.1,
          iconSize * 0.5,
          0,
          iconSize * 0.5,
        );
        dropPath.quadraticBezierTo(
          -iconSize * 0.1,
          iconSize * 0.5,
          -iconSize * 0.2,
          iconSize * 0.3,
        );
        dropPath.quadraticBezierTo(
          -iconSize * 0.35,
          -iconSize * 0.1,
          0,
          -iconSize * 0.5,
        );
        canvas.drawPath(dropPath, paint);

        // Add shine effect
        paint.color = Colors.white.withOpacity(0.5);
        canvas.drawCircle(
          Offset(-iconSize * 0.1, -iconSize * 0.2),
          iconSize * 0.1,
          paint,
        );
        break;

      case MemoryEmotion.nostalgic:
        // Draw butterfly 🦋
        paint.color = const Color(0xFFBA55D3);
        // Left wing
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-iconSize * 0.25, 0),
            width: iconSize * 0.4,
            height: iconSize * 0.6,
          ),
          paint,
        );
        // Right wing
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(iconSize * 0.25, 0),
            width: iconSize * 0.4,
            height: iconSize * 0.6,
          ),
          paint,
        );
        // Body
        paint.color = const Color(0xFF000000);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: iconSize * 0.15,
            height: iconSize * 0.5,
          ),
          paint,
        );
        break;

      case MemoryEmotion.peaceful:
        // Draw leaf 🍃
        paint.color = const Color(0xFF90EE90);
        final leafPath = Path()
          ..moveTo(0, -iconSize * 0.4)
          ..quadraticBezierTo(
            iconSize * 0.3,
            -iconSize * 0.2,
            iconSize * 0.2,
            0,
          )
          ..quadraticBezierTo(iconSize * 0.3, iconSize * 0.2, 0, iconSize * 0.4)
          ..quadraticBezierTo(
            -iconSize * 0.3,
            iconSize * 0.2,
            -iconSize * 0.2,
            0,
          )
          ..quadraticBezierTo(
            -iconSize * 0.3,
            -iconSize * 0.2,
            0,
            -iconSize * 0.4,
          );
        canvas.drawPath(leafPath, paint);

        // Leaf vein
        paint.color = const Color(0xFF228B22);
        paint.strokeWidth = 1;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(0, -iconSize * 0.4),
          Offset(0, iconSize * 0.4),
          paint,
        );
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
