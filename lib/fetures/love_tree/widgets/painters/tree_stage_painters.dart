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

// 3. Growing State - Energetic young tree with wild, asymmetric growth
class GrowingPainter extends TreeStagePainter {
  GrowingPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.5;
    final windSway = math.sin(elapsedTime * math.pi) * 2.5;

    // Draw young, slightly bent trunk
    _drawYouthfulTrunk(canvas, centerX, groundY, trunkHeight, 12, windSway);

    // Asymmetric, wild branches - like a young tree growing freely
    final branches = [
      // Lower branches - thicker, spreading wide
      {
        'y': 0.3,
        'length': 55.0,
        'angle': -1.1,
        'width': 4.5,
        'leaves': 16,
        'twigs': 2,
      },
      {
        'y': 0.33,
        'length': 48.0,
        'angle': 0.85,
        'width': 4.0,
        'leaves': 14,
        'twigs': 2,
      },

      // Middle branches - medium spread
      {
        'y': 0.48,
        'length': 52.0,
        'angle': -0.9,
        'width': 3.8,
        'leaves': 15,
        'twigs': 2,
      },
      {
        'y': 0.51,
        'length': 58.0,
        'angle': 0.75,
        'width': 4.2,
        'leaves': 17,
        'twigs': 2,
      },
      {
        'y': 0.62,
        'length': 45.0,
        'angle': -0.7,
        'width': 3.5,
        'leaves': 13,
        'twigs': 1,
      },
      {
        'y': 0.65,
        'length': 50.0,
        'angle': 0.8,
        'width': 3.7,
        'leaves': 14,
        'twigs': 2,
      },

      // Upper branches - reaching upward
      {
        'y': 0.75,
        'length': 42.0,
        'angle': -0.55,
        'width': 3.2,
        'leaves': 11,
        'twigs': 1,
      },
      {
        'y': 0.78,
        'length': 38.0,
        'angle': 0.6,
        'width': 3.0,
        'leaves': 10,
        'twigs': 1,
      },
      {
        'y': 0.86,
        'length': 35.0,
        'angle': -0.4,
        'width': 2.8,
        'leaves': 9,
        'twigs': 1,
      },
      {
        'y': 0.89,
        'length': 32.0,
        'angle': 0.3,
        'width': 2.5,
        'leaves': 8,
        'twigs': 1,
      },

      // Top branches - small, upward reaching
      {
        'y': 0.94,
        'length': 28.0,
        'angle': -0.2,
        'width': 2.2,
        'leaves': 6,
        'twigs': 0,
      },
      {
        'y': 0.96,
        'length': 25.0,
        'angle': 0.15,
        'width': 2.0,
        'leaves': 5,
        'twigs': 0,
      },
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawEnergeticBranch(canvas, startOffset, branchData, elapsedTime);
    }
  }

  void _drawYouthfulTrunk(
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
              const Color(0xFF7D5E54),
              const Color(0xFF6D4C41),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    // Slightly curved trunk showing youthful flexibility
    final path = Path()
      ..moveTo(centerX - width * 0.7, groundY + 3)
      ..quadraticBezierTo(
        centerX - width * 0.5,
        groundY - height * 0.2,
        centerX - width * 0.4 + sway * 0.5,
        groundY - height * 0.5,
      )
      ..quadraticBezierTo(
        centerX - width * 0.3 + sway * 0.8,
        groundY - height * 0.75,
        centerX - width * 0.28 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.28 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.3 + sway * 0.8,
        groundY - height * 0.75,
        centerX + width * 0.4 + sway * 0.5,
        groundY - height * 0.5,
      )
      ..quadraticBezierTo(
        centerX + width * 0.5,
        groundY - height * 0.2,
        centerX + width * 0.7,
        groundY + 3,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Young bark texture - less pronounced
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 20) {
      final curve = math.sin(i * 0.3) * 2;
      canvas.drawLine(
        Offset(centerX - width * 0.25 + curve, groundY - i),
        Offset(centerX + width * 0.2 + curve, groundY - i - 10),
        barkPaint,
      );
    }

    // Add some green tint to show vitality
    final vitalityPaint = Paint()
      ..color = const Color(0xFF7CB342).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, vitalityPaint);
  }

  void _drawEnergeticBranch(
    Canvas canvas,
    Offset start,
    Map<String, dynamic> branchData,
    double elapsedTime,
  ) {
    final length = branchData['length'] as double;
    final angle = branchData['angle'] as double;
    final width = branchData['width'] as double;
    final leafCount = branchData['leaves'] as int;
    final twigCount = branchData['twigs'] as int;

    // Main branch with slight curve
    final branchPaint = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader =
          LinearGradient(
            colors: [
              const Color(0xFF6D4C41),
              const Color(0xFF8D6E63),
              const Color(0xFF9D7E73),
            ],
          ).createShader(
            Rect.fromPoints(start, Offset(start.dx + 100, start.dy + 100)),
          );

    final controlPoint = Offset(
      start.dx + (length * 0.55) * math.sin(angle),
      start.dy - (length * 0.6) * math.cos(angle),
    );

    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    final branchPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

    canvas.drawPath(branchPath, branchPaint);

    // Draw small twigs branching off
    for (int i = 0; i < twigCount; i++) {
      final twigT = 0.5 + (i * 0.25);
      final twigStart = Offset(
        lerpDouble(start.dx, endPoint.dx, twigT)!,
        lerpDouble(start.dy, endPoint.dy, twigT)!,
      );
      _drawSmallTwig(canvas, twigStart, angle, width * 0.5, elapsedTime);
    }

    // Draw abundant leaf cluster
    _drawWildLeafCluster(canvas, endPoint, leafCount, angle, elapsedTime);
  }

  void _drawSmallTwig(
    Canvas canvas,
    Offset start,
    double baseAngle,
    double width,
    double elapsedTime,
  ) {
    final random = math.Random(start.dx.toInt() + start.dy.toInt());
    final twigAngle = baseAngle + (random.nextDouble() - 0.5) * 1.2;
    final twigLength = 12 + random.nextDouble() * 8;

    final twigPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final twigEnd = Offset(
      start.dx + twigLength * math.sin(twigAngle),
      start.dy - twigLength * math.cos(twigAngle),
    );

    canvas.drawLine(start, twigEnd, twigPaint);

    // Few leaves on twig
    _drawWildLeafCluster(canvas, twigEnd, 4, twigAngle, elapsedTime);
  }

  void _drawWildLeafCluster(
    Canvas canvas,
    Offset center,
    int count,
    double baseAngle,
    double elapsedTime,
  ) {
    final random = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (random.nextDouble() - 0.5) * 3.5;
      final distance = 6 + random.nextDouble() * 22;
      final rustleX = math.sin(elapsedTime * math.pi * 2 + i * 0.8) * 2;
      final rustleY = math.cos(elapsedTime * math.pi * 1.8 + i * 0.6) * 1.5;

      final leafPos = Offset(
        center.dx + math.cos(angle) * distance + rustleX,
        center.dy + math.sin(angle) * distance + rustleY,
      );

      final leafSize = 14 + random.nextDouble() * 6;
      final leafRotation = angle + (random.nextDouble() - 0.5) * 1.2;

      // Mix different leaf shapes for wild, natural look
      if (i % 3 == 0) {
        _drawRoundLeaf(canvas, leafPos, leafSize * 0.9, leafRotation);
      } else {
        _drawNarrowLeaf(canvas, leafPos, leafSize, leafRotation);
      }
    }
  }

  void _drawNarrowLeaf(
    Canvas canvas,
    Offset center,
    double length,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFA5D6A7), // Fresh light green
              const Color(0xFF81C784), // Medium green
              const Color(0xFF66BB6A), // Vibrant green
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(-length * 0.12, -length * 0.5, length * 0.24, length),
          );

    // Narrow, elongated leaf
    final path = Path()
      ..moveTo(0, -length * 0.5)
      ..quadraticBezierTo(length * 0.09, -length * 0.2, length * 0.12, 0)
      ..quadraticBezierTo(length * 0.09, length * 0.2, 0, length * 0.5)
      ..quadraticBezierTo(-length * 0.09, length * 0.2, -length * 0.12, 0)
      ..quadraticBezierTo(-length * 0.09, -length * 0.2, 0, -length * 0.5);

    canvas.drawPath(path, leafPaint);

    // Central vein
    final veinPaint = Paint()
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.4)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, -length * 0.45),
      Offset(0, length * 0.45),
      veinPaint,
    );

    canvas.restore();
  }

  void _drawRoundLeaf(
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
          const Color(0xFFA5D6A7), // Light center
          const Color(0xFF81C784), // Medium
          const Color(0xFF66BB6A), // Darker edge
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size * 0.6));

    // Rounder, broader leaf shape
    final path = Path()
      ..moveTo(0, -size * 0.4)
      ..quadraticBezierTo(size * 0.5, -size * 0.3, size * 0.6, 0)
      ..quadraticBezierTo(size * 0.5, size * 0.3, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.5, size * 0.3, -size * 0.6, 0)
      ..quadraticBezierTo(-size * 0.5, -size * 0.3, 0, -size * 0.4);

    canvas.drawPath(path, leafPaint);

    // Vein pattern
    final veinPaint = Paint()
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.35)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Central vein
    canvas.drawLine(
      Offset(0, -size * 0.35),
      Offset(0, size * 0.4),
      veinPaint,
    );

    // Side veins
    for (int i = 0; i < 2; i++) {
      final yPos = -size * 0.15 + (i * size * 0.25);
      canvas.drawLine(
        Offset(0, yPos),
        Offset(size * 0.3, yPos + size * 0.1),
        veinPaint,
      );
      canvas.drawLine(
        Offset(0, yPos),
        Offset(-size * 0.3, yPos + size * 0.1),
        veinPaint,
      );
    }

    canvas.restore();
  }
}

// 4. Blooming State - Enhanced with delicate branches and more flowers
class BloomingPainter extends TreeStagePainter {
  BloomingPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.2;
    final windSway = math.sin(elapsedTime * math.pi) * 2;

    // Draw elegant thin trunk
    _drawElegantTrunk(canvas, centerX, groundY, trunkHeight, 16, windSway);

    // More branches with better distribution
    final branches = [
      {'y': 0.22, 'length': 75.0, 'angle': -1.1, 'width': 4.5, 'flowers': 15},
      {'y': 0.25, 'length': 75.0, 'angle': 1.1, 'width': 4.5, 'flowers': 15},
      {'y': 0.38, 'length': 70.0, 'angle': -0.95, 'width': 4.0, 'flowers': 13},
      {'y': 0.41, 'length': 70.0, 'angle': 0.95, 'width': 4.0, 'flowers': 13},
      {'y': 0.52, 'length': 65.0, 'angle': -0.85, 'width': 3.8, 'flowers': 12},
      {'y': 0.55, 'length': 65.0, 'angle': 0.85, 'width': 3.8, 'flowers': 12},
      {'y': 0.66, 'length': 58.0, 'angle': -0.75, 'width': 3.5, 'flowers': 10},
      {'y': 0.69, 'length': 58.0, 'angle': 0.75, 'width': 3.5, 'flowers': 10},
      {'y': 0.78, 'length': 52.0, 'angle': -0.65, 'width': 3.2, 'flowers': 9},
      {'y': 0.81, 'length': 52.0, 'angle': 0.65, 'width': 3.2, 'flowers': 9},
      {'y': 0.88, 'length': 45.0, 'angle': -0.5, 'width': 2.8, 'flowers': 7},
      {'y': 0.91, 'length': 45.0, 'angle': 0.5, 'width': 2.8, 'flowers': 7},
      {'y': 0.96, 'length': 38.0, 'angle': -0.2, 'width': 2.5, 'flowers': 6},
      {'y': 0.98, 'length': 38.0, 'angle': 0.2, 'width': 2.5, 'flowers': 6},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawDelicateBranch(canvas, startOffset, branchData, elapsedTime);
    }
  }

  void _drawElegantTrunk(
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
              const Color(0xFF5D4037),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    final path = Path()
      ..moveTo(centerX - width * 0.75, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.55,
        groundY - height * 0.15,
        centerX - width * 0.45,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.3 + sway * 0.8,
        groundY - height * 0.7,
        centerX - width * 0.25 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.25 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.3 + sway * 0.8,
        groundY - height * 0.7,
        centerX + width * 0.45,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX + width * 0.55,
        groundY - height * 0.15,
        centerX + width * 0.75,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Subtle bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 18) {
      final curve = math.sin(i * 0.25) * 2;
      canvas.drawLine(
        Offset(centerX - width * 0.2 + curve, groundY - i),
        Offset(centerX + width * 0.15 + curve, groundY - i - 8),
        barkPaint,
      );
    }
  }

  void _drawDelicateBranch(
    Canvas canvas,
    Offset start,
    Map<String, dynamic> branchData,
    double elapsedTime,
  ) {
    final length = branchData['length'] as double;
    final angle = branchData['angle'] as double;
    final width = branchData['width'] as double;
    final flowerCount = branchData['flowers'] as int;

    // Thin, graceful branch
    final branchPaint = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader =
          LinearGradient(
            colors: [
              const Color(0xFF6D4C41),
              const Color(0xFF8D6E63),
            ],
          ).createShader(
            Rect.fromPoints(start, Offset(start.dx + 100, start.dy + 100)),
          );

    final controlPoint = Offset(
      start.dx + (length * 0.5) * math.sin(angle),
      start.dy - (length * 0.65) * math.cos(angle),
    );

    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    final branchPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

    canvas.drawPath(branchPath, branchPaint);

    // Draw abundant flowers and leaves
    _drawBlossomCluster(canvas, endPoint, flowerCount, angle, elapsedTime);
  }

  void _drawBlossomCluster(
    Canvas canvas,
    Offset center,
    int count,
    double baseAngle,
    double elapsedTime,
  ) {
    final random = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (random.nextDouble() - 0.5) * 2.8;
      final distance = 8 + random.nextDouble() * 28;
      final sway = math.sin(elapsedTime * math.pi + i * 0.5) * 1.5;

      final position = Offset(
        center.dx + math.cos(angle) * distance + sway,
        center.dy + math.sin(angle) * distance,
      );

      // Mix of flowers and leaves
      if (i % 3 == 0) {
        final bloom = 0.85 + (math.sin(elapsedTime * math.pi * 2 + i) * 0.15);
        _drawPrettyFlower(canvas, position, bloom);
      } else {
        final leafSize = 11 + random.nextDouble() * 4;
        _drawPrettyLeaf(canvas, position, leafSize, angle);
      }
    }
  }

  void _drawPrettyFlower(Canvas canvas, Offset center, double bloom) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final petalPaint = Paint()..style = PaintingStyle.fill;

    // Draw 5 elegant petals
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i * math.pi * 2 / 5));

      petalPaint.shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFFFF),
              const Color(0xFFFFE4E1),
              const Color(0xFFFFB6C1),
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(-6 * bloom, -12 * bloom, 12 * bloom, 12 * bloom),
          );

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          3.5 * bloom,
          -5 * bloom,
          2 * bloom,
          -10 * bloom,
        )
        ..quadraticBezierTo(
          0,
          -8 * bloom,
          -2 * bloom,
          -10 * bloom,
        )
        ..quadraticBezierTo(-3.5 * bloom, -5 * bloom, 0, 0);
      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Golden center with detail
    final centerPaint = Paint()..style = PaintingStyle.fill;

    // Outer center
    centerPaint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 3.5 * bloom, centerPaint);

    // Inner center detail
    centerPaint.color = const Color(0xFFFFA500);
    canvas.drawCircle(Offset.zero, 2 * bloom, centerPaint);

    // Tiny dots for pollen effect
    centerPaint.color = const Color(0xFFFF8C00).withValues(alpha: 0.6);
    for (int i = 0; i < 6; i++) {
      final dotAngle = (i * math.pi * 2 / 6);
      final dotPos = Offset(
        math.cos(dotAngle) * 2 * bloom,
        math.sin(dotAngle) * 2 * bloom,
      );
      canvas.drawCircle(dotPos, 0.6 * bloom, centerPaint);
    }

    canvas.restore();
  }

  void _drawPrettyLeaf(
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
          const Color(0xFF9CCC65),
          const Color(0xFF7CB342),
          const Color(0xFF689F38),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(-size * 0.5, -size * 0.5, size, size));

    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.4, -size * 0.25, size * 0.48, 0)
      ..quadraticBezierTo(size * 0.4, size * 0.25, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.4, size * 0.25, -size * 0.48, 0)
      ..quadraticBezierTo(-size * 0.4, -size * 0.25, 0, -size * 0.5);

    canvas.drawPath(path, leafPaint);

    // Subtle vein
    final veinPaint = Paint()
      ..color = const Color(0xFF558B2F).withValues(alpha: 0.3)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, -size * 0.4),
      Offset(0, size * 0.4),
      veinPaint,
    );

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
    ..moveTo(centerX - width * 0.5, groundY + 5)
    ..quadraticBezierTo(
      centerX - width * 0.4,
      groundY,
      centerX - width * 0.4,
      groundY - 10,
    )
    ..lineTo(centerX - width * 0.25 + sway, groundY - height)
    ..lineTo(centerX + width * 0.25 + sway, groundY - height)
    ..lineTo(centerX + width * 0.4, groundY - 10)
    ..quadraticBezierTo(
      centerX + width * 0.4,
      groundY,
      centerX + width * 0.5,
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

// 6. Completed State - Optimized for performance
class CompletedPainter extends TreeStagePainter {
  CompletedPainter({required super.elapsedTime, required super.tree});

  @override
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    groundPainter.paint(canvas, size, groundY);

    final trunkHeight = tree.height * 1.15;
    final windSway = math.sin(elapsedTime * math.pi) * 3;

    // Elegant double glow
    final glowPulse = (math.sin(elapsedTime * math.pi * 2) + 1) / 2;

    final outerGlow = Paint()
      ..color = const Color(0xFFFFA500).withValues(alpha: 0.08 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(
      Offset(centerX, groundY - trunkHeight * 0.5),
      140,
      outerGlow,
    );

    final innerGlow = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.12 * glowPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(
      Offset(centerX, groundY - trunkHeight * 0.5),
      100,
      innerGlow,
    );

    // Draw elegant thin trunk
    _drawElegantTrunk(canvas, centerX, groundY, trunkHeight, 18, windSway);

    // More branches with better distribution
    final branches = [
      {'y': 0.18, 'length': 90.0, 'angle': -1.1, 'width': 6.0, 'leaves': 14},
      {'y': 0.2, 'length': 90.0, 'angle': 1.1, 'width': 6.0, 'leaves': 14},
      {'y': 0.32, 'length': 85.0, 'angle': -0.95, 'width': 5.5, 'leaves': 12},
      {'y': 0.34, 'length': 85.0, 'angle': 0.95, 'width': 5.5, 'leaves': 12},
      {'y': 0.45, 'length': 80.0, 'angle': -0.85, 'width': 5.0, 'leaves': 11},
      {'y': 0.47, 'length': 80.0, 'angle': 0.85, 'width': 5.0, 'leaves': 11},
      {'y': 0.58, 'length': 72.0, 'angle': -0.75, 'width': 4.5, 'leaves': 10},
      {'y': 0.6, 'length': 72.0, 'angle': 0.75, 'width': 4.5, 'leaves': 10},
      {'y': 0.7, 'length': 65.0, 'angle': -0.65, 'width': 4.0, 'leaves': 9},
      {'y': 0.72, 'length': 65.0, 'angle': 0.65, 'width': 4.0, 'leaves': 9},
      {'y': 0.82, 'length': 55.0, 'angle': -0.5, 'width': 3.5, 'leaves': 8},
      {'y': 0.84, 'length': 55.0, 'angle': 0.5, 'width': 3.5, 'leaves': 8},
      {'y': 0.92, 'length': 45.0, 'angle': -0.3, 'width': 3.0, 'leaves': 6},
      {'y': 0.94, 'length': 45.0, 'angle': 0.3, 'width': 3.0, 'leaves': 6},
      {'y': 0.98, 'length': 35.0, 'angle': 0.0, 'width': 2.5, 'leaves': 5},
    ];

    for (var branchData in branches) {
      final y = groundY - trunkHeight * (branchData['y'] as double);
      final branchSway = windSway * (1.0 - (branchData['y'] as double));
      final startOffset = Offset(centerX + branchSway, y);
      _drawGracefulBranch(canvas, startOffset, branchData, elapsedTime);
    }
  }

  void _drawElegantTrunk(
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
              const Color(0xFF4A3428),
              const Color(0xFF8D6E63),
              const Color(0xFF6D4C41),
              const Color(0xFF5D4037),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    // Elegant tapered trunk
    final path = Path()
      ..moveTo(centerX - width * 0.9, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.7,
        groundY - height * 0.15,
        centerX - width * 0.5,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.35 + sway * 0.8,
        groundY - height * 0.7,
        centerX - width * 0.25 + sway,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.25 + sway, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.35 + sway * 0.8,
        groundY - height * 0.7,
        centerX + width * 0.5,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX + width * 0.7,
        groundY - height * 0.15,
        centerX + width * 0.9,
        groundY + 5,
      )
      ..close();

    canvas.drawPath(path, trunkPaint);

    // Refined bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 18) {
      final curve = math.sin(i * 0.2) * 3;
      canvas.drawLine(
        Offset(centerX - width * 0.25 + curve, groundY - i),
        Offset(centerX + width * 0.2 + curve, groundY - i - 8),
        barkPaint,
      );
    }

    // Golden highlights on trunk
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 45) {
      canvas.drawLine(
        Offset(centerX - width * 0.2, groundY - i - 10),
        Offset(centerX + width * 0.15, groundY - i - 16),
        highlightPaint,
      );
    }
  }

  void _drawGracefulBranch(
    Canvas canvas,
    Offset start,
    Map<String, dynamic> branchData,
    double elapsedTime,
  ) {
    final length = branchData['length'] as double;
    final angle = branchData['angle'] as double;
    final width = branchData['width'] as double;
    final leafCount = branchData['leaves'] as int;

    // Curved branch with gradient
    final branchPaint = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader =
          LinearGradient(
            colors: [
              const Color(0xFF6D4C41),
              const Color(0xFFA1887F),
            ],
          ).createShader(
            Rect.fromPoints(start, Offset(start.dx + 100, start.dy + 100)),
          );

    final controlPoint = Offset(
      start.dx + (length * 0.5) * math.sin(angle),
      start.dy - (length * 0.6) * math.cos(angle),
    );

    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    final branchPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );

    canvas.drawPath(branchPath, branchPaint);

    // Draw lush leaf cluster
    _drawLushLeafCluster(canvas, endPoint, leafCount, angle, elapsedTime);
  }

  void _drawLushLeafCluster(
    Canvas canvas,
    Offset center,
    int count,
    double baseAngle,
    double elapsedTime,
  ) {
    final random = math.Random(center.dx.toInt());

    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (random.nextDouble() - 0.5) * 2.5;
      final distance = 8 + random.nextDouble() * 25;
      final rustleX = math.sin(elapsedTime * math.pi * 2 + i * 0.7) * 2.5;
      final rustleY = math.cos(elapsedTime * math.pi * 1.5 + i * 0.5) * 1.5;

      final leafPos = Offset(
        center.dx + math.cos(angle) * distance + rustleX,
        center.dy + math.sin(angle) * distance + rustleY,
      );

      final leafSize = 13 + random.nextDouble() * 5;
      final isGolden = i % 4 == 0;
      final leafRotation = angle + (random.nextDouble() - 0.5) * 0.8;

      _drawBeautifulLeaf(
        canvas,
        leafPos,
        leafSize,
        leafRotation,
        isGolden,
        elapsedTime,
      );
    }
  }

  void _drawBeautifulLeaf(
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

    final leafPaint = Paint()..style = PaintingStyle.fill;

    if (isGolden) {
      // Golden shimmering leaves
      final shimmer = (math.sin(elapsedTime * math.pi * 3) + 1) / 2;
      leafPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(
            const Color(0xFFFFD700),
            const Color(0xFFFFA500),
            shimmer * 0.5,
          )!,
          const Color(0xFFDAA520),
          const Color(0xFF8BC34A),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(-size * 0.5, -size * 0.5, size, size));
    } else {
      // Vibrant green leaves with gradient
      leafPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF9CCC65),
          const Color(0xFF7CB342),
          const Color(0xFF558B2F),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(-size * 0.5, -size * 0.5, size, size));
    }

    // Elegant leaf shape
    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.45, -size * 0.25, size * 0.5, 0)
      ..quadraticBezierTo(size * 0.45, size * 0.25, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.45, size * 0.25, -size * 0.5, 0)
      ..quadraticBezierTo(-size * 0.45, -size * 0.25, 0, -size * 0.5);

    canvas.drawPath(path, leafPaint);

    // Central vein
    final veinPaint = Paint()
      ..color = isGolden
          ? const Color(0xFFDAA520).withValues(alpha: 0.4)
          : const Color(0xFF558B2F).withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, -size * 0.4),
      Offset(0, size * 0.4),
      veinPaint,
    );

    // Side veins for detail
    for (int i = 0; i < 3; i++) {
      final yPos = -size * 0.3 + (i * size * 0.3);
      canvas.drawLine(
        Offset(0, yPos),
        Offset(size * 0.25, yPos + size * 0.08),
        veinPaint,
      );
      canvas.drawLine(
        Offset(0, yPos),
        Offset(-size * 0.25, yPos + size * 0.08),
        veinPaint,
      );
    }

    canvas.restore();
  }
}
