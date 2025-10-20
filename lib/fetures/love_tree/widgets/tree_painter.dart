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

    // Scale everything 2x larger
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

    final stemHeight = tree.height * 2; // 20-40 pixels
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

    // Draw 2 small leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF6B9B78)
      ..style = PaintingStyle.fill;

    // Left leaf
    _drawLeaf(
      canvas,
      Offset(centerX - 8, groundY - stemHeight * 0.6),
      8,
      leafPaint,
      -0.4,
    );
    // Right leaf
    _drawLeaf(
      canvas,
      Offset(centerX + 8, groundY - stemHeight * 0.7),
      8,
      leafPaint,
      0.4,
    );
  }

  // Draw growing stage (young tree with branches)
  void _drawGrowing(Canvas canvas, Size size, double centerX, double groundY) {
    _drawGround(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5; // 60-90 pixels
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

    // Draw young branches
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final branchStartY = groundY - trunkHeight * 0.4;
    final branchLength = 30.0;

    // 4 small branches
    for (int i = 0; i < 4; i++) {
      final y = branchStartY - (i * 15);
      final side = i % 2 == 0 ? 1 : -1;
      final angle = side * 0.6;

      _drawBranch(
        canvas,
        Offset(centerX, y),
        branchLength,
        angle,
        branchPaint,
      );

      // Add small leaves
      final leafEnd = Offset(
        centerX + side * branchLength * math.cos(angle),
        y - branchLength * math.sin(angle),
      );
      _drawLeafCluster(canvas, leafEnd, 3, 10);
    }
  }

  // Draw blooming stage (fuller tree with flowers)
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

    // Draw main branches
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final branches = [
      {'y': 0.3, 'angle': -0.7, 'side': -1, 'length': 50.0},
      {'y': 0.4, 'angle': 0.7, 'side': 1, 'length': 55.0},
      {'y': 0.5, 'angle': -0.6, 'side': -1, 'length': 60.0},
      {'y': 0.6, 'angle': 0.6, 'side': 1, 'length': 50.0},
      {'y': 0.7, 'angle': -0.5, 'side': -1, 'length': 45.0},
      {'y': 0.8, 'angle': 0.5, 'side': 1, 'length': 40.0},
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      _drawBranch(
        canvas,
        Offset(centerX, y),
        branch['length'] as double,
        (branch['side'] as int) * (branch['angle'] as double),
        branchPaint,
      );

      // Add leaf clusters
      final leafEnd = Offset(
        centerX +
            (branch['side'] as int) *
                (branch['length'] as double) *
                math.cos((branch['side'] as int) * (branch['angle'] as double)),
        y -
            (branch['length'] as double) *
                math.sin((branch['side'] as int) * (branch['angle'] as double)),
      );
      _drawLeafCluster(canvas, leafEnd, 6, 12);
    }

    // Draw crown
    _drawCanopy(canvas, Offset(centerX, groundY - trunkHeight), 80, 0.7);
  }

  // Draw mature stage (full tree)
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

    // Draw extensive branch system
    _drawBranchSystem(canvas, centerX, groundY, trunkHeight);

    // Draw large canopy
    _drawCanopy(canvas, Offset(centerX, groundY - trunkHeight), 120, 1.0);
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
    final end = Offset(
      start.dx + length * math.cos(angle),
      start.dy - length * math.sin(angle),
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

  // Helper: Draw canopy (tree crown)
  void _drawCanopy(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final canopyPaint = Paint()
      ..color = const Color(0xFF6B9B78).withOpacity(opacity * 0.6)
      ..style = PaintingStyle.fill;

    // Draw multiple overlapping circles for organic look
    canvas.drawCircle(center, radius, canopyPaint);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.4, center.dy - radius * 0.2),
      radius * 0.7,
      canopyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.2),
      radius * 0.7,
      canopyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      radius * 0.6,
      canopyPaint,
    );

    // Darker outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF4A7C59).withOpacity(opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, outlinePaint);
  }

  // Helper: Draw branch system
  void _drawBranchSystem(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    final branchPaint = Paint()
      ..color = const Color(0xFF7D5A3C)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final branches = [
      {'y': 0.2, 'angle': -0.8, 'side': -1, 'length': 70.0},
      {'y': 0.25, 'angle': 0.8, 'side': 1, 'length': 70.0},
      {'y': 0.35, 'angle': -0.7, 'side': -1, 'length': 80.0},
      {'y': 0.4, 'angle': 0.7, 'side': 1, 'length': 80.0},
      {'y': 0.5, 'angle': -0.6, 'side': -1, 'length': 85.0},
      {'y': 0.55, 'angle': 0.6, 'side': 1, 'length': 85.0},
      {'y': 0.65, 'angle': -0.5, 'side': -1, 'length': 75.0},
      {'y': 0.7, 'angle': 0.5, 'side': 1, 'length': 75.0},
      {'y': 0.8, 'angle': -0.4, 'side': -1, 'length': 60.0},
      {'y': 0.85, 'angle': 0.4, 'side': 1, 'length': 60.0},
    ];

    for (var branch in branches) {
      final y = groundY - trunkHeight * (branch['y'] as double);
      _drawBranch(
        canvas,
        Offset(centerX, y),
        branch['length'] as double,
        (branch['side'] as int) * (branch['angle'] as double),
        branchPaint,
      );

      // Add leaf clusters
      final leafEnd = Offset(
        centerX +
            (branch['side'] as int) *
                (branch['length'] as double) *
                math.cos((branch['side'] as int) * (branch['angle'] as double)),
        y -
            (branch['length'] as double) *
                math.sin((branch['side'] as int) * (branch['angle'] as double)),
      );
      _drawLeafCluster(canvas, leafEnd, 8, 14);
    }
  }

  // Draw memories as decorations
  void _drawMemories(Canvas canvas, Size size, double centerX, double groundY) {
    if (memories.isEmpty) return;

    final trunkHeight =
        tree.height *
        (tree.stage == TreeStage.seedling
            ? 2
            : tree.stage == TreeStage.growing
            ? 1.5
            : 1.2);

    // Distribute memories around the tree
    for (int i = 0; i < memories.length; i++) {
      final memory = memories[i];
      final angle = (i / memories.length) * math.pi * 2;

      // Position based on tree stage
      double radius;
      double yOffset;

      switch (tree.stage) {
        case TreeStage.seedling:
          radius = 15;
          yOffset = trunkHeight * 0.5;
          break;
        case TreeStage.growing:
          radius = 35;
          yOffset = trunkHeight * 0.6;
          break;
        case TreeStage.blooming:
          radius = 60;
          yOffset = trunkHeight * 0.7;
          break;
        case TreeStage.mature:
          radius = 90;
          yOffset = trunkHeight * 0.6;
          break;
        case TreeStage.notPlanted:
          continue;
      }

      final x = centerX + math.cos(angle) * radius;
      final y = groundY - yOffset + math.sin(angle) * radius * 0.5;

      // Draw memory icon based on emotion
      _drawMemoryIcon(canvas, Offset(x, y), memory.emotion);
    }
  }

  // Draw memory icon
  void _drawMemoryIcon(Canvas canvas, Offset position, MemoryEmotion emotion) {
    final size = 20.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

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
          canvas.drawCircle(Offset(0, -size * 0.4), size * 0.3, paint);
          canvas.restore();
        }
        paint.color = const Color(0xFFFFD700);
        canvas.drawCircle(Offset.zero, size * 0.2, paint);
        break;

      case MemoryEmotion.excited:
        // Draw bird 🐦
        paint.color = const Color(0xFF87CEEB);
        // Body
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: size * 0.6,
            height: size * 0.8,
          ),
          paint,
        );
        // Wings
        final wingPath = Path()
          ..moveTo(-size * 0.3, 0)
          ..quadraticBezierTo(-size * 0.6, -size * 0.3, -size * 0.4, 0);
        canvas.drawPath(wingPath, paint);
        canvas.save();
        canvas.scale(-1, 1);
        canvas.drawPath(wingPath, paint);
        canvas.restore();
        break;

      case MemoryEmotion.joyful:
        // Draw fruit 🍎
        paint.color = const Color(0xFFFF6347);
        canvas.drawCircle(Offset.zero, size * 0.4, paint);
        paint.color = const Color(0xFF228B22);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, -size * 0.5),
            width: size * 0.3,
            height: size * 0.2,
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
          final outerRadius = size * 0.5;
          final innerRadius = size * 0.2;

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
        heartPath.moveTo(0, size * 0.3);
        heartPath.cubicTo(
          -size * 0.5,
          -size * 0.1,
          -size * 0.5,
          -size * 0.5,
          0,
          -size * 0.2,
        );
        heartPath.cubicTo(
          size * 0.5,
          -size * 0.5,
          size * 0.5,
          -size * 0.1,
          0,
          size * 0.3,
        );
        canvas.drawPath(heartPath, paint);
        break;

      case MemoryEmotion.sad:
        // Draw raindrop 💧
        paint.color = const Color(0xFF4682B4);
        final dropPath = Path();
        dropPath.moveTo(0, -size * 0.4);
        dropPath.quadraticBezierTo(size * 0.3, 0, 0, size * 0.4);
        dropPath.quadraticBezierTo(-size * 0.3, 0, 0, -size * 0.4);
        canvas.drawPath(dropPath, paint);
        break;

      case MemoryEmotion.nostalgic:
        // Draw butterfly 🦋
        paint.color = const Color(0xFFBA55D3);
        // Left wing
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-size * 0.25, 0),
            width: size * 0.4,
            height: size * 0.6,
          ),
          paint,
        );
        // Right wing
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size * 0.25, 0),
            width: size * 0.4,
            height: size * 0.6,
          ),
          paint,
        );
        // Body
        paint.color = const Color(0xFF000000);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: size * 0.15,
            height: size * 0.5,
          ),
          paint,
        );
        break;

      case MemoryEmotion.peaceful:
        // Draw leaf 🍃
        paint.color = const Color(0xFF90EE90);
        final leafPath = Path()
          ..moveTo(0, -size * 0.4)
          ..quadraticBezierTo(size * 0.3, -size * 0.2, size * 0.2, 0)
          ..quadraticBezierTo(size * 0.3, size * 0.2, 0, size * 0.4)
          ..quadraticBezierTo(-size * 0.3, size * 0.2, -size * 0.2, 0)
          ..quadraticBezierTo(-size * 0.3, -size * 0.2, 0, -size * 0.4);
        canvas.drawPath(leafPath, paint);

        // Leaf vein
        paint.color = const Color(0xFF228B22);
        paint.strokeWidth = 1;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(0, -size * 0.4), Offset(0, size * 0.4), paint);
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
