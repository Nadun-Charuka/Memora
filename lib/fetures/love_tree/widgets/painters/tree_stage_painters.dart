// FILE: lib/painters/tree_stage_painters.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memora/models/tree_model.dart';
import 'ground_painter.dart';

// The Abstract Base Class
abstract class TreeStagePainter {
  final Animation<double> animation;
  final LoveTree tree;
  final GroundPainter groundPainter;
  final math.Random random;

  TreeStagePainter({required this.animation, required this.tree})
    : groundPainter = GroundPainter(animation: animation),
      random = math.Random(1); // Seeded for consistent "randomness"

  void paint(Canvas canvas, Size size, double centerX, double groundY);
}

// 1. Unplanted State Painter (No changes needed here)
class UnplantedPainter extends TreeStagePainter {
  UnplantedPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    // ... (This class is correct)
    groundPainter.paint(canvas, size, groundY);

    final glowPaint = Paint()
      ..color = const Color(0xFF6B5345).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(centerX, groundY + 20), 40, glowPaint);

    final spotPaint = Paint()
      ..color = const Color(0xFF6B5345)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, groundY + 20), 30, spotPaint);

    final scale = 1.0 + math.sin(animation.value * math.pi * 2) * 0.2;
    canvas.save();
    canvas.translate(centerX, groundY - 10);
    canvas.scale(scale);

    final textPainter = TextPainter(
      text: const TextSpan(text: '🌱', style: TextStyle(fontSize: 40)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();
  }
}

// 2. Seedling State Painter - ADVANCED (No changes needed here)
class SeedlingPainter extends TreeStagePainter {
  SeedlingPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    // ... (This class is correct)
    groundPainter.paint(canvas, size, groundY);

    final stemHeight = tree.height * 2;
    final sway = math.sin(animation.value * math.pi) * 2; // Slower sway

    final stemPaint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromCenter(
      center: Offset(centerX, groundY - stemHeight / 2),
      width: 4,
      height: stemHeight,
    );
    stemPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [const Color(0xFF4A7C59), const Color(0xFF6B9B78)],
    ).createShader(rect);

    final path = Path()
      ..moveTo(centerX - 2, groundY)
      ..quadraticBezierTo(
        centerX + sway,
        groundY - stemHeight / 2,
        centerX - 2 + sway,
        groundY - stemHeight,
      )
      ..lineTo(centerX + 2 + sway, groundY - stemHeight)
      ..quadraticBezierTo(
        centerX + 2 + sway,
        groundY - stemHeight / 2,
        centerX + 2,
        groundY,
      )
      ..close();
    canvas.drawPath(path, stemPaint);

    _drawDetailedLeaf(
      canvas,
      Offset(centerX - 5 + sway, groundY - stemHeight * 0.6),
      12,
      -0.6,
    );
    _drawDetailedLeaf(
      canvas,
      Offset(centerX + 5 - sway, groundY - stemHeight * 0.8),
      12,
      0.6,
    );
  }
}

// 3. Growing State Painter - ADVANCED
class GrowingPainter extends TreeStagePainter {
  GrowingPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5;
    final windSway = math.sin(animation.value * math.pi) * 3;

    // MODIFIED: Pass 'animation' into the helper function
    _drawRealisticTrunk(
      canvas,
      centerX,
      groundY,
      trunkHeight,
      12,
      windSway,
      animation,
    );

    final branches = [
      {'y': 0.4, 'length': 40.0, 'angle': -0.8, 'width': 5.0},
      {'y': 0.42, 'length': 40.0, 'angle': 0.8, 'width': 5.0},
      {'y': 0.65, 'length': 35.0, 'angle': -0.7, 'width': 4.0},
      {'y': 0.67, 'length': 35.0, 'angle': 0.7, 'width': 4.0},
      {'y': 0.9, 'length': 25.0, 'angle': 0.2, 'width': 3.0},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      // MODIFIED: Pass 'animation' into the helper function
      _drawRealisticBranch(canvas, startOffset, branchData, 1, animation);
    }
  }
}

// 4. Blooming State Painter - ADVANCED
class BloomingPainter extends TreeStagePainter {
  BloomingPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.2;
    final windSway = math.sin(animation.value * math.pi) * 4;

    // MODIFIED: Pass 'animation' into the helper function
    _drawRealisticTrunk(
      canvas,
      centerX,
      groundY,
      trunkHeight,
      20,
      windSway,
      animation,
    );

    final branches = [
      {'y': 0.3, 'length': 60.0, 'angle': -0.9, 'width': 8.0},
      {'y': 0.32, 'length': 60.0, 'angle': 0.9, 'width': 8.0},
      {'y': 0.5, 'length': 55.0, 'angle': -0.7, 'width': 7.0},
      {'y': 0.52, 'length': 55.0, 'angle': 0.7, 'width': 7.0},
      {'y': 0.7, 'length': 45.0, 'angle': -0.6, 'width': 6.0},
      {'y': 0.72, 'length': 45.0, 'angle': 0.6, 'width': 6.0},
      {'y': 0.9, 'length': 35.0, 'angle': 0.2, 'width': 5.0},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      // MODIFIED: Pass 'animation' into the helper function
      _drawRealisticBranch(canvas, startOffset, branchData, 2, animation);
    }
  }
}

// 5. Mature State Painter - ADVANCED
class MaturePainter extends TreeStagePainter {
  MaturePainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height;
    final windSway = math.sin(animation.value * math.pi) * 5;

    // MODIFIED: Pass 'animation' into the helper function
    _drawRealisticTrunk(
      canvas,
      centerX,
      groundY,
      trunkHeight,
      25,
      windSway,
      animation,
    );

    final branches = [
      {'y': 0.2, 'length': 80.0, 'angle': -1.0, 'width': 12.0},
      {'y': 0.22, 'length': 80.0, 'angle': 1.0, 'width': 12.0},
      {'y': 0.4, 'length': 75.0, 'angle': -0.8, 'width': 10.0},
      {'y': 0.42, 'length': 75.0, 'angle': 0.8, 'width': 10.0},
      {'y': 0.6, 'length': 65.0, 'angle': -0.7, 'width': 9.0},
      {'y': 0.62, 'length': 65.0, 'angle': 0.7, 'width': 9.0},
      {'y': 0.78, 'length': 50.0, 'angle': -0.6, 'width': 7.0},
      {'y': 0.8, 'length': 50.0, 'angle': 0.6, 'width': 7.0},
      {'y': 0.92, 'length': 40.0, 'angle': 0.2, 'width': 6.0},
    ];
    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      // MODIFIED: Pass 'animation' into the helper function
      _drawRealisticBranch(canvas, startOffset, branchData, 3, animation);
    }
  }
}

// --- NEW ADVANCED HELPER FUNCTIONS ---

// MODIFIED: Added 'Animation<double> animation' parameter
void _drawRealisticTrunk(
  Canvas canvas,
  double centerX,
  double groundY,
  double height,
  double width,
  double sway,
  Animation<double> animation,
) {
  final trunkPaint = Paint();
  final rect = Rect.fromLTWH(
    centerX - width,
    groundY - height,
    width * 2,
    height,
  );
  trunkPaint.shader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [const Color(0xFF5D4037), const Color(0xFF8D6E63)],
  ).createShader(rect);

  final path = Path()
    ..moveTo(centerX - width * 0.7, groundY + 5)
    ..quadraticBezierTo(
      centerX - width * 0.5,
      groundY,
      centerX - width * 0.5,
      groundY - 10,
    )
    ..lineTo(centerX - width * 0.3 + sway, groundY - height)
    ..lineTo(centerX + width * 0.3 + sway, groundY - height)
    ..lineTo(centerX + width * 0.5, groundY - 10)
    ..quadraticBezierTo(
      centerX + width * 0.5,
      groundY,
      centerX + width * 0.7,
      groundY + 5,
    )
    ..close();

  canvas.drawPath(path, trunkPaint);

  final barkPaint = Paint()
    ..color = Colors.black.withOpacity(0.15)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  for (double i = 0; i < height; i += 15) {
    final textureSway = math.sin(animation.value * math.pi * 2 + i) * 0.5;
    canvas.drawLine(
      Offset(centerX - 2 + textureSway, groundY - i),
      Offset(centerX + 2 + textureSway, groundY - i - 10),
      barkPaint,
    );
  }
}

// MODIFIED: Added 'Animation<double> animation' parameter
void _drawRealisticBranch(
  Canvas canvas,
  Offset start,
  Map<String, double> branchData,
  int depth,
  Animation<double> animation,
) {
  if (depth <= 0) return;

  final length = branchData['length']!;
  final angle = branchData['angle']!;
  final width = branchData['width']!;

  final paint = Paint()
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;
  final rect = Rect.fromPoints(
    start,
    Offset(start.dx + length, start.dy + length),
  );
  paint.shader = LinearGradient(
    colors: [const Color(0xFF6D4C41), const Color(0xFFA1887F)],
  ).createShader(rect);

  final endPoint = Offset(
    start.dx + length * math.sin(angle),
    start.dy - length * math.cos(angle),
  );

  final branchPath = Path()..moveTo(start.dx, start.dy);
  for (double t = 0; t <= 1.0; t += 0.1) {
    final x = lerpDouble(start.dx, endPoint.dx, t)!;
    final y = lerpDouble(start.dy, endPoint.dy, t)!;
    final currentWidth = lerpDouble(width, 1.0, t)!;
    branchPath.addOval(
      Rect.fromCircle(center: Offset(x, y), radius: currentWidth * 0.5),
    );
  }

  canvas.drawPath(branchPath, paint);

  // MODIFIED: Pass 'animation' into the helper function
  _drawNaturalLeafCluster(canvas, endPoint, 5, 12, angle, animation);

  if (depth > 1) {
    final subBranchData = {
      'length': length * 0.6,
      'angle': angle + (angle > 0 ? -0.5 : 0.5),
      'width': width * 0.6,
    };
    final subBranchStart = Offset(
      lerpDouble(start.dx, endPoint.dx, 0.6)!,
      lerpDouble(start.dy, endPoint.dy, 0.6)!,
    );
    // MODIFIED: Pass 'animation' into the recursive call
    _drawRealisticBranch(
      canvas,
      subBranchStart,
      subBranchData,
      depth - 1,
      animation,
    );
  }
}

void _drawDetailedLeaf(
  Canvas canvas,
  Offset center,
  double size,
  double rotation,
) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);

  final paint = Paint()..style = PaintingStyle.fill;
  paint.shader = RadialGradient(
    colors: [const Color(0xFF7CB342), const Color(0xFF558B2F)],
  ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));

  final path = Path()
    ..moveTo(0, -size / 2)
    ..quadraticBezierTo(size * 0.5, -size * 0.2, size * 0.6, 0)
    ..quadraticBezierTo(size * 0.5, size * 0.2, 0, size / 2)
    ..quadraticBezierTo(-size * 0.5, size * 0.2, -size * 0.6, 0)
    ..quadraticBezierTo(-size * 0.5, -size * 0.2, 0, -size / 2);
  canvas.drawPath(path, paint);

  final veinPaint = Paint()
    ..color = Colors.black.withOpacity(0.1)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), veinPaint);

  canvas.restore();
}

// MODIFIED: Added 'Animation<double> animation' parameter
void _drawNaturalLeafCluster(
  Canvas canvas,
  Offset center,
  int count,
  double size,
  double baseRotation,
  Animation<double> animation,
) {
  final random = math.Random(center.dx.toInt());

  for (int i = 0; i < count; i++) {
    final angle = baseRotation + (random.nextDouble() - 0.5) * 1.5;
    final distance = size * 0.5 + random.nextDouble() * size;
    final rustleX = math.sin(animation.value * math.pi * 2 + i) * 3;
    final rustleY = math.cos(animation.value * math.pi * 2 + i) * 2;

    final offset = Offset(
      center.dx + math.cos(angle) * distance + rustleX,
      center.dy + math.sin(angle) * distance + rustleY,
    );
    _drawDetailedLeaf(
      canvas,
      offset,
      size * (0.8 + random.nextDouble() * 0.4),
      angle,
    );
  }
}
