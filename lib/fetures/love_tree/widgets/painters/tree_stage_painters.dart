import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'ground_painter.dart';

// The Abstract Base Class
abstract class TreeStagePainter {
  final double elapsedTime;
  final LoveTree tree;
  final GroundPainter groundPainter;
  final math.Random random;

  TreeStagePainter({required this.elapsedTime, required this.tree}) // CHANGED
    : groundPainter = GroundPainter(elapsedTime: elapsedTime), // CHANGED
      random = math.Random(1);

  void paint(Canvas canvas, Size size, double centerX, double groundY);
}

// 1. Unplanted State Painter
class UnplantedPainter extends TreeStagePainter {
  UnplantedPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final glowPaint = Paint()
      ..color = const Color(0xFF6B5345).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(centerX, groundY + 20), 40, glowPaint);

    final spotPaint = Paint()
      ..color = const Color(0xFF6B5345)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, groundY + 20), 30, spotPaint);

    final scale = 1.0 + math.sin(elapsedTime * math.pi * 2) * 0.2;
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
  SeedlingPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final stemHeight = tree.height * 2;
    final sway = math.sin(elapsedTime * math.pi * 2) * 3;

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
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -size * 0.4), Offset(0, size * 0.4), veinPaint);

    canvas.restore();
  }
}

// 3. Growing State - Young tree with spreading branches
class GrowingPainter extends TreeStagePainter {
  GrowingPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5;
    final windSway = math.sin(elapsedTime * math.pi * 2) * 2;

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
      _drawSpreadingBranch(canvas, startOffset, branchData, elapsedTime);
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
      ..color = Colors.black.withValues(alpha: 0.2)
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
    double elapsedTime,
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
    _drawLeafCluster(canvas, endPoint, leafCount, 12, angle, elapsedTime);
  }

  void _drawLeafCluster(
    Canvas canvas,
    Offset center,
    int count,
    double size,
    double baseAngle,
    double elapsedTime,
  ) {
    final clusterRandom = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (clusterRandom.nextDouble() - 0.5) * 2.0;
      final distance = clusterRandom.nextDouble() * size * 1.5;
      final rustle = math.sin(elapsedTime * math.pi * 4 + i) * 2;

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
  BloomingPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.2;
    final windSway = math.sin(elapsedTime * math.pi * 2) * 3;

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
      {'y': 0.99, 'length': 45.0, 'angle': 0.1, 'flowers': 6},
      {'y': 0.99, 'length': 45.0, 'angle': -0.1, 'flowers': 6},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawFloweringBranch(canvas, startOffset, branchData, elapsedTime);
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
      ..color = Colors.black.withValues(alpha: 0.25)
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
    double elapsedTime,
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
    _drawFlowerCluster(canvas, endPoint, flowerCount, angle, elapsedTime);
  }

  void _drawFlowerCluster(
    Canvas canvas,
    Offset center,
    int count,
    double baseAngle,
    double elapsedTime,
  ) {
    final clusterRandom = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (clusterRandom.nextDouble() - 0.5) * 2.5;
      final distance = clusterRandom.nextDouble() * 20;
      final bloom = (math.sin(elapsedTime * math.pi * 2 + i) + 1) / 2;

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

// 5. Mature State - Mature tree with lots of branches

class MaturePainter extends TreeStagePainter {
  MaturePainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height;
    final windSway = math.sin(elapsedTime * math.pi) * 5;

    // MODIFIED: Pass 'animation' into the helper function
    _drawRealisticTrunk(
      canvas,
      centerX,
      groundY,
      trunkHeight,
      25,
      windSway,
      elapsedTime,
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
      _drawRealisticBranch(canvas, startOffset, branchData, 3, elapsedTime);
    }
  }
}

void _drawRealisticTrunk(
  Canvas canvas,
  double centerX,
  double groundY,
  double height,
  double width,
  double sway,
  double elapsedTime,
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
    ..color = Colors.black.withValues(alpha: 0.15)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  for (double i = 0; i < height; i += 15) {
    final textureSway = math.sin(elapsedTime * math.pi * 2 + i) * 0.5;
    canvas.drawLine(
      Offset(centerX - 2 + textureSway, groundY - i),
      Offset(centerX + 2 + textureSway, groundY - i - 10),
      barkPaint,
    );
  }
}

void _drawRealisticBranch(
  Canvas canvas,
  Offset start,
  Map<String, double> branchData,
  int depth,
  double elapsedTime,
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

  _drawNaturalLeafCluster(
    canvas,
    endPoint,
    5,
    12,
    angle,
    elapsedTime,
  );

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

    _drawRealisticBranch(
      canvas,
      subBranchStart,
      subBranchData,
      depth - 1,
      elapsedTime,
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
    ..color = Colors.black.withValues(alpha: 0.1)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), veinPaint);

  canvas.restore();
}

void _drawNaturalLeafCluster(
  Canvas canvas,
  Offset center,
  int count,
  double size,
  double baseRotation,
  double elapsedTime,
) {
  final random = math.Random(center.dx.toInt());

  for (int i = 0; i < count; i++) {
    final angle = baseRotation + (random.nextDouble() - 0.5) * 1.5;
    final distance = size * 0.5 + random.nextDouble() * size;
    final rustleX = math.sin(elapsedTime * math.pi * 2 + i) * 3;
    final rustleY = math.cos(elapsedTime * math.pi * 2 + i) * 2;

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

// 6. Completed State - Magnificent tree with golden glow and celebration effects
class CompletedPainter extends TreeStagePainter {
  CompletedPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.1;
    final windSway = math.sin(elapsedTime * math.pi) * 4;

    // Draw magical glow around the tree
    _drawCelebrationGlow(canvas, centerX, groundY, trunkHeight, elapsedTime);

    // Draw majestic trunk
    _drawMajesticTrunk(
      canvas,
      centerX,
      groundY,
      trunkHeight,
      28,
      windSway,
      elapsedTime,
    );

    // Draw abundant branches with golden accents
    final branches = [
      {'y': 0.15, 'length': 90.0, 'angle': -1.1, 'width': 14.0},
      {'y': 0.17, 'length': 90.0, 'angle': 1.1, 'width': 14.0},
      {'y': 0.32, 'length': 85.0, 'angle': -0.9, 'width': 12.0},
      {'y': 0.34, 'length': 85.0, 'angle': 0.9, 'width': 12.0},
      {'y': 0.48, 'length': 80.0, 'angle': -0.8, 'width': 11.0},
      {'y': 0.5, 'length': 80.0, 'angle': 0.8, 'width': 11.0},
      {'y': 0.64, 'length': 70.0, 'angle': -0.7, 'width': 10.0},
      {'y': 0.66, 'length': 70.0, 'angle': 0.7, 'width': 10.0},
      {'y': 0.78, 'length': 60.0, 'angle': -0.6, 'width': 8.0},
      {'y': 0.8, 'length': 60.0, 'angle': 0.6, 'width': 8.0},
      {'y': 0.9, 'length': 45.0, 'angle': -0.3, 'width': 7.0},
      {'y': 0.92, 'length': 45.0, 'angle': 0.3, 'width': 7.0},
      {'y': 0.98, 'length': 30.0, 'angle': 0.1, 'width': 6.0},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawGoldenBranch(canvas, startOffset, branchData, 3, elapsedTime);
    }

    // Draw floating sparkles
    _drawCelebrationSparkles(
      canvas,
      centerX,
      groundY,
      trunkHeight,
      elapsedTime,
    );
  }

  void _drawCelebrationGlow(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double elapsedTime,
  ) {
    final glowPulse = (math.sin(elapsedTime * math.pi * 2) + 1) / 2;

    // Multiple layers of glow for depth
    final glowPaint1 = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.15 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(
      Offset(centerX, groundY - height * 0.5),
      150 + glowPulse * 20,
      glowPaint1,
    );

    final glowPaint2 = Paint()
      ..color = const Color(0xFFFFA500).withValues(alpha: 0.1 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(
      Offset(centerX, groundY - height * 0.5),
      180 + glowPulse * 30,
      glowPaint2,
    );

    // Subtle rainbow halo
    final haloPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFFB6C1).withValues(alpha: 0.05),
              const Color(0xFF9B85C0).withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(centerX, groundY - height * 0.5),
              radius: 200,
            ),
          );

    canvas.drawCircle(
      Offset(centerX, groundY - height * 0.5),
      200,
      haloPaint,
    );
  }

  void _drawMajesticTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
    double elapsedTime,
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
      colors: [
        const Color(0xFF4A3428),
        const Color(0xFF8D6E63),
        const Color(0xFF6D4C41),
        const Color(0xFF4A3428),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    ).createShader(rect);

    final path = Path()
      ..moveTo(centerX - width * 0.8, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.6,
        groundY - 5,
        centerX - width * 0.55,
        groundY - 15,
      )
      ..lineTo(centerX - width * 0.35 + sway, groundY - height)
      ..lineTo(centerX + width * 0.35 + sway, groundY - height)
      ..lineTo(centerX + width * 0.55, groundY - 15)
      ..quadraticBezierTo(
        centerX + width * 0.6,
        groundY - 5,
        centerX + width * 0.8,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Enhanced bark texture with golden highlights
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final goldenBarkPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 12) {
      final textureSway = math.sin(elapsedTime * math.pi * 2 + i * 0.1) * 2;
      final offsetX = math.sin(i * 0.2) * 4;

      // Dark bark lines
      canvas.drawLine(
        Offset(centerX - width * 0.3 + offsetX + textureSway, groundY - i),
        Offset(centerX + width * 0.2 + offsetX + textureSway, groundY - i - 8),
        barkPaint,
      );

      // Golden accent lines (less frequent)
      if (i % 30 == 0) {
        canvas.drawLine(
          Offset(centerX - width * 0.25 + offsetX, groundY - i - 5),
          Offset(centerX + width * 0.15 + offsetX, groundY - i - 12),
          goldenBarkPaint,
        );
      }
    }

    // Add trunk glow effect
    final trunkGlowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, trunkGlowPaint);
  }

  void _drawGoldenBranch(
    Canvas canvas,
    Offset start,
    Map<String, double> branchData,
    int depth,
    double elapsedTime,
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
      colors: [
        const Color(0xFF6D4C41),
        const Color(0xFFA1887F),
        const Color(0xFFBCAA9F),
      ],
    ).createShader(rect);

    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    // Draw branch with tapering
    final branchPath = Path()..moveTo(start.dx, start.dy);
    for (double t = 0; t <= 1.0; t += 0.08) {
      final x = lerpDouble(start.dx, endPoint.dx, t)!;
      final y = lerpDouble(start.dy, endPoint.dy, t)!;
      final currentWidth = lerpDouble(width, 1.5, t)!;
      branchPath.addOval(
        Rect.fromCircle(center: Offset(x, y), radius: currentWidth * 0.5),
      );
    }
    canvas.drawPath(branchPath, paint);

    // Add golden shimmer to branch tips
    if (depth == 3) {
      final shimmerPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(
          alpha: 0.2 * ((math.sin(elapsedTime * math.pi * 2) + 1) / 2),
        )
        ..strokeWidth = width * 0.8
        ..strokeCap = StrokeCap.round;

      final shimmerPath = Path()..moveTo(start.dx, start.dy);
      for (double t = 0.7; t <= 1.0; t += 0.1) {
        final x = lerpDouble(start.dx, endPoint.dx, t)!;
        final y = lerpDouble(start.dy, endPoint.dy, t)!;
        shimmerPath.addOval(
          Rect.fromCircle(center: Offset(x, y), radius: width * 0.4),
        );
      }
      canvas.drawPath(shimmerPath, shimmerPaint);
    }

    // Draw luxurious leaf cluster
    _drawLuxuriousLeafCluster(canvas, endPoint, 8, 14, angle, elapsedTime);

    // Draw sub-branches
    if (depth > 1) {
      final subBranchData = {
        'length': length * 0.65,
        'angle': angle + (angle > 0 ? -0.4 : 0.4),
        'width': width * 0.65,
      };
      final subBranchStart = Offset(
        lerpDouble(start.dx, endPoint.dx, 0.6)!,
        lerpDouble(start.dy, endPoint.dy, 0.6)!,
      );

      _drawGoldenBranch(
        canvas,
        subBranchStart,
        subBranchData,
        depth - 1,
        elapsedTime,
      );
    }
  }

  void _drawLuxuriousLeafCluster(
    Canvas canvas,
    Offset center,
    int count,
    double size,
    double baseRotation,
    double elapsedTime,
  ) {
    final random = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseRotation + (random.nextDouble() - 0.5) * 1.8;
      final distance = size * 0.4 + random.nextDouble() * size;
      final rustleX = math.sin(elapsedTime * math.pi * 2 + i * 0.5) * 3;
      final rustleY = math.cos(elapsedTime * math.pi * 2 + i * 0.5) * 2;

      final offset = Offset(
        center.dx + math.cos(angle) * distance + rustleX,
        center.dy + math.sin(angle) * distance + rustleY,
      );

      // Mix of regular and golden-tinted leaves
      final isGoldenLeaf = i % 4 == 0;
      _drawEnhancedLeaf(
        canvas,
        offset,
        size * (0.9 + random.nextDouble() * 0.3),
        angle,
        isGoldenLeaf,
        elapsedTime,
      );
    }
  }

  void _drawEnhancedLeaf(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
    bool isGolden,
    double elapsedTime,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final paint = Paint()..style = PaintingStyle.fill;

    if (isGolden) {
      // Golden accent leaves
      final shimmer = (math.sin(elapsedTime * math.pi * 2) + 1) / 2;
      paint.shader = RadialGradient(
        colors: [
          Color.lerp(
            const Color(0xFFFFD700),
            const Color(0xFFFFA500),
            shimmer,
          )!,
          const Color(0xFF7CB342),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));
    } else {
      // Regular vibrant leaves
      paint.shader = RadialGradient(
        colors: [
          const Color(0xFF8BC34A),
          const Color(0xFF7CB342),
          const Color(0xFF558B2F),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));
    }

    final path = Path()
      ..moveTo(0, -size / 2)
      ..quadraticBezierTo(size * 0.5, -size * 0.2, size * 0.6, 0)
      ..quadraticBezierTo(size * 0.5, size * 0.2, 0, size / 2)
      ..quadraticBezierTo(-size * 0.5, size * 0.2, -size * 0.6, 0)
      ..quadraticBezierTo(-size * 0.5, -size * 0.2, 0, -size / 2);
    canvas.drawPath(path, paint);

    // Enhanced vein
    final veinPaint = Paint()
      ..color = isGolden
          ? const Color(0xFFFFD700).withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), veinPaint);

    // Add subtle glow to golden leaves
    if (isGolden) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);
    }

    canvas.restore();
  }

  void _drawCelebrationSparkles(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double elapsedTime,
  ) {
    final random = math.Random(20);

    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * math.pi * 3;
      final radius = 50 + random.nextDouble() * 360;
      final sparklePhase = (elapsedTime + i * 0.05) % 1.0;
      final opacity = math.sin(sparklePhase * math.pi);

      if (opacity <= 0) continue;

      final x = centerX + math.cos(angle + elapsedTime * 2) * radius;
      final y =
          groundY - height * 0.5 + math.sin(angle + elapsedTime * 2) * radius;

      final sparkleSize = 2.0 + random.nextDouble() * 3.0;

      // Draw sparkle cross
      final sparklePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: opacity * 0.8)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      // Horizontal line
      canvas.drawLine(
        Offset(x - sparkleSize, y),
        Offset(x + sparkleSize, y),
        sparklePaint,
      );

      // Vertical line
      canvas.drawLine(
        Offset(x, y - sparkleSize),
        Offset(x, y + sparkleSize),
        sparklePaint,
      );

      // Center glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), sparkleSize * 0.5, glowPaint);
    }
  }
}
