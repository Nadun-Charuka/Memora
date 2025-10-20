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
      random = math.Random(1);

  void paint(Canvas canvas, Size size, double centerX, double groundY);
}

// 1. Unplanted State Painter
class UnplantedPainter extends TreeStagePainter {
  UnplantedPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
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

// 2. Seedling State - Young sprout with first leaves
class SeedlingPainter extends TreeStagePainter {
  SeedlingPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final stemHeight = tree.height * 2;
    final sway = math.sin(animation.value * math.pi * 2) * 3;

    // Draw thin, delicate stem
    final stemPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF4A7C59),
              const Color(0xFF7CB342),
            ],
          ).createShader(
            Rect.fromLTWH(
              centerX - 2,
              groundY - stemHeight,
              4,
              stemHeight,
            ),
          );

    final stemPath = Path()
      ..moveTo(centerX - 1.5, groundY)
      ..quadraticBezierTo(
        centerX + sway * 0.5,
        groundY - stemHeight * 0.5,
        centerX - 1 + sway,
        groundY - stemHeight,
      )
      ..lineTo(centerX + 1 + sway, groundY - stemHeight)
      ..quadraticBezierTo(
        centerX + sway * 0.5,
        groundY - stemHeight * 0.5,
        centerX + 1.5,
        groundY,
      )
      ..close();
    canvas.drawPath(stemPath, stemPaint);

    // Draw young leaves
    _drawYoungLeaf(
      canvas,
      Offset(centerX - 8 + sway, groundY - stemHeight * 0.5),
      15,
      -0.7,
    );
    _drawYoungLeaf(
      canvas,
      Offset(centerX + 8 + sway * 0.8, groundY - stemHeight * 0.7),
      15,
      0.7,
    );
    _drawYoungLeaf(
      canvas,
      Offset(centerX - 6 + sway * 0.9, groundY - stemHeight * 0.85),
      12,
      -0.5,
    );
    _drawYoungLeaf(
      canvas,
      Offset(centerX + sway, groundY - stemHeight),
      18,
      0.1,
    );
  }

  void _drawYoungLeaf(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9CCC65),
          const Color(0xFF7CB342),
          const Color(0xFF558B2F),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));

    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.6, -size * 0.2, size * 0.7, size * 0.1)
      ..quadraticBezierTo(size * 0.5, size * 0.3, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.5, size * 0.3, -size * 0.7, size * 0.1)
      ..quadraticBezierTo(-size * 0.6, -size * 0.2, 0, -size * 0.5);
    canvas.drawPath(path, leafPaint);

    final veinPaint = Paint()
      ..color = const Color(0xFF558B2F).withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -size * 0.4), Offset(0, size * 0.4), veinPaint);

    canvas.restore();
  }
}

// 3. Growing State - Young tree with spreading branches
class GrowingPainter extends TreeStagePainter {
  GrowingPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5;
    final windSway = math.sin(animation.value * math.pi * 2) * 2;

    // Draw broader trunk
    _drawYoungTrunk(canvas, centerX, groundY, trunkHeight, 10, windSway);

    // Draw spreading branches with more foliage
    final branches = [
      {'y': 0.35, 'length': 45.0, 'angle': -0.9, 'leaves': 8},
      {'y': 0.38, 'length': 45.0, 'angle': 0.9, 'leaves': 8},
      {'y': 0.55, 'length': 50.0, 'angle': -0.7, 'leaves': 10},
      {'y': 0.58, 'length': 50.0, 'angle': 0.7, 'leaves': 10},
      {'y': 0.75, 'length': 40.0, 'angle': -0.6, 'leaves': 7},
      {'y': 0.78, 'length': 40.0, 'angle': 0.6, 'leaves': 7},
      {'y': 0.9, 'length': 30.0, 'angle': 0.0, 'leaves': 6},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawSpreadingBranch(canvas, startOffset, branchData, animation);
    }
  }

  void _drawYoungTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    final trunkPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF6D4C41),
              const Color(0xFF8D6E63),
              const Color(0xFF5D4037),
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    final path = Path()
      ..moveTo(centerX - width * 0.8, groundY + 3)
      ..lineTo(centerX - width * 0.4, groundY - 5)
      ..lineTo(centerX - width * 0.3 + sway, groundY - height)
      ..lineTo(centerX + width * 0.3 + sway, groundY - height)
      ..lineTo(centerX + width * 0.4, groundY - 5)
      ..lineTo(centerX + width * 0.8, groundY + 3)
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 12) {
      canvas.drawLine(
        Offset(centerX - width * 0.3, groundY - i),
        Offset(centerX + width * 0.2, groundY - i - 8),
        barkPaint,
      );
    }
  }

  void _drawSpreadingBranch(
    Canvas canvas,
    Offset start,
    Map<String, dynamic> branchData,
    Animation<double> animation,
  ) {
    final length = branchData['length'] as double;
    final angle = branchData['angle'] as double;
    final leafCount = branchData['leaves'] as int;

    final branchPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    canvas.drawLine(start, endPoint, branchPaint);

    // Draw leaf cluster at branch end
    _drawLeafCluster(canvas, endPoint, leafCount, 12, angle, animation);
  }

  void _drawLeafCluster(
    Canvas canvas,
    Offset center,
    int count,
    double size,
    double baseAngle,
    Animation<double> animation,
  ) {
    final clusterRandom = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (clusterRandom.nextDouble() - 0.5) * 2.0;
      final distance = clusterRandom.nextDouble() * size * 1.5;
      final rustle = math.sin(animation.value * math.pi * 4 + i) * 2;

      final leafPos = Offset(
        center.dx + math.cos(angle) * distance + rustle,
        center.dy + math.sin(angle) * distance,
      );

      final leafSize = size * (0.7 + clusterRandom.nextDouble() * 0.6);
      _drawYoungLeaf(canvas, leafPos, leafSize, angle);
    }
  }

  void _drawYoungLeaf(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7CB342),
          const Color(0xFF558B2F),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));

    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.5, -size * 0.2, size * 0.6, 0)
      ..quadraticBezierTo(size * 0.5, size * 0.2, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.5, size * 0.2, -size * 0.6, 0)
      ..quadraticBezierTo(-size * 0.5, -size * 0.2, 0, -size * 0.5);
    canvas.drawPath(path, leafPaint);

    canvas.restore();
  }
}

// 4. Blooming State - Tree with flowers
class BloomingPainter extends TreeStagePainter {
  BloomingPainter({required super.animation, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.2;
    final windSway = math.sin(animation.value * math.pi * 2) * 3;

    // Draw mature trunk
    _drawMatureTrunk(canvas, centerX, groundY, trunkHeight, 18, windSway);

    // Draw flowering branches
    final branches = [
      {'y': 0.25, 'length': 70.0, 'angle': -1.0, 'flowers': 12},
      {'y': 0.28, 'length': 70.0, 'angle': 1.0, 'flowers': 12},
      {'y': 0.45, 'length': 65.0, 'angle': -0.8, 'flowers': 10},
      {'y': 0.48, 'length': 65.0, 'angle': 0.8, 'flowers': 10},
      {'y': 0.65, 'length': 55.0, 'angle': -0.7, 'flowers': 8},
      {'y': 0.68, 'length': 55.0, 'angle': 0.7, 'flowers': 8},
      {'y': 0.82, 'length': 45.0, 'angle': -0.5, 'flowers': 6},
      {'y': 0.85, 'length': 45.0, 'angle': 0.5, 'flowers': 6},
      {'y': 0.99, 'length': 25.0, 'angle': 0.1, 'flowers': 6},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawFloweringBranch(canvas, startOffset, branchData, animation);
    }
  }

  void _drawMatureTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    final trunkPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF5D4037),
              const Color(0xFF8D6E63),
              const Color(0xFF6D4C41),
            ],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    final path = Path()
      ..moveTo(centerX - width, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.6,
        groundY - 10,
        centerX - width * 0.5,
        groundY - 20,
      )
      ..lineTo(centerX - width * 0.35 + sway, groundY - height)
      ..lineTo(centerX + width * 0.35 + sway, groundY - height)
      ..lineTo(centerX + width * 0.5, groundY - 20)
      ..quadraticBezierTo(
        centerX + width * 0.6,
        groundY - 10,
        centerX + width,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Detailed bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 10) {
      final offset = math.sin(i * 0.3) * 3;
      canvas.drawLine(
        Offset(centerX - width * 0.3 + offset, groundY - i),
        Offset(centerX + width * 0.2 + offset, groundY - i - 7),
        barkPaint,
      );
    }
  }

  void _drawFloweringBranch(
    Canvas canvas,
    Offset start,
    Map<String, dynamic> branchData,
    Animation<double> animation,
  ) {
    final length = branchData['length'] as double;
    final angle = branchData['angle'] as double;
    final flowerCount = branchData['flowers'] as int;

    final branchPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final midPoint = Offset(
      start.dx + (length * 0.6) * math.sin(angle),
      start.dy - (length * 0.6) * math.cos(angle),
    );

    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    final branchPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(midPoint.dx, midPoint.dy, endPoint.dx, endPoint.dy);

    canvas.drawPath(branchPath, branchPaint);

    // Draw flowers and leaves
    _drawFlowerCluster(canvas, endPoint, flowerCount, angle, animation);
  }

  void _drawFlowerCluster(
    Canvas canvas,
    Offset center,
    int count,
    double baseAngle,
    Animation<double> animation,
  ) {
    final clusterRandom = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (clusterRandom.nextDouble() - 0.5) * 2.5;
      final distance = clusterRandom.nextDouble() * 20;
      final bloom = (math.sin(animation.value * math.pi * 2 + i) + 1) / 2;

      final flowerPos = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      if (i % 3 == 0) {
        _drawFlower(canvas, flowerPos, bloom);
      } else {
        _drawLeafSimple(canvas, flowerPos, 10, angle);
      }
    }
  }

  void _drawFlower(Canvas canvas, Offset center, double bloom) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final petalPaint = Paint()..style = PaintingStyle.fill;

    // Draw petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i * math.pi * 2 / 5));

      petalPaint.shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFFFB6C1),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8 * bloom));

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(4 * bloom, -6 * bloom, 0, -10 * bloom)
        ..quadraticBezierTo(-4 * bloom, -6 * bloom, 0, 0);
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Center
    petalPaint.shader = null;
    petalPaint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 3 * bloom, petalPaint);

    canvas.restore();
  }

  void _drawLeafSimple(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final leafPaint = Paint()
      ..color = const Color(0xFF7CB342)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.4, -size * 0.2, size * 0.5, 0)
      ..quadraticBezierTo(size * 0.4, size * 0.2, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.4, size * 0.2, -size * 0.5, 0)
      ..quadraticBezierTo(-size * 0.4, -size * 0.2, 0, -size * 0.5);
    canvas.drawPath(path, leafPaint);

    canvas.restore();
  }
}

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
