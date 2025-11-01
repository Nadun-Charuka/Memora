import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';
import 'base_stage_painter.dart';

/// Mature Stage (48-58 memories)
/// Fully developed, majestic tree with strong presence
class MaturePainter extends BaseTreeStagePainter {
  MaturePainter({required super.elapsedTime, required super.tree});

  @override
  TreeBranchSchema get schema => BranchSchemas.mature;

  @override
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  ) {
    // Strong, noble trunk
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
            stops: const [0.0, 0.35, 0.65, 1.0],
          ).createShader(
            Rect.fromLTWH(
              centerX - width,
              groundY - height,
              width * 2,
              height,
            ),
          );

    // Strong, stable trunk with minimal sway
    final path = Path()
      ..moveTo(centerX - width * 0.9, groundY + 5)
      ..quadraticBezierTo(
        centerX - width * 0.7,
        groundY - height * 0.15,
        centerX - width * 0.55,
        groundY - height * 0.4,
      )
      ..quadraticBezierTo(
        centerX - width * 0.35 + sway * 0.6,
        groundY - height * 0.7,
        centerX - width * 0.3 + sway * 0.8,
        groundY - height,
      )
      ..lineTo(centerX + width * 0.3 + sway * 0.8, groundY - height)
      ..quadraticBezierTo(
        centerX + width * 0.35 + sway * 0.6,
        groundY - height * 0.7,
        centerX + width * 0.55,
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

    // Rich, detailed bark texture
    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < height; i += 15) {
      final textureSway = math.sin(elapsedTime * math.pi * 2 + i) * 0.5;
      final curve = math.sin(i * 0.2) * 2.5;

      canvas.drawLine(
        Offset(centerX - width * 0.3 + curve + textureSway, groundY - i),
        Offset(centerX + width * 0.25 + curve + textureSway, groundY - i - 10),
        barkPaint,
      );
    }

    // Horizontal bark ridges
    final ridgePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double i = 20; i < height; i += 30) {
      canvas.drawArc(
        Rect.fromLTWH(
          centerX - width * 0.4,
          groundY - i - 5,
          width * 0.8,
          10,
        ),
        0,
        math.pi,
        false,
        ridgePaint,
      );
    }

    // Moss/lichen spots for age
    final mossPaint = Paint()
      ..color = const Color(0xFF7CB342).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 8; i++) {
      final mossY = groundY - (random.nextDouble() * height * 0.6);
      final mossX = centerX + (random.nextDouble() - 0.5) * width * 1.2;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mossX, mossY),
          width: 8 + random.nextDouble() * 6,
          height: 6 + random.nextDouble() * 4,
        ),
        mossPaint,
      );
    }
  }

  @override
  void paintSingleBranch(
    Canvas canvas,
    Offset start,
    BranchConfig config,
    double trunkHeight,
  ) {
    // Override to add sub-branches for mature tree
    final endPoint = Offset(
      start.dx + config.length * math.sin(config.angle),
      start.dy - config.length * math.cos(config.angle),
    );

    // Main branch
    final branchPaint = Paint()
      ..strokeWidth = config.width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader =
          LinearGradient(
            colors: getBranchColors(),
          ).createShader(
            Rect.fromPoints(start, endPoint),
          );

    final controlPoint = Offset(
      start.dx + (config.length * 0.5) * math.sin(config.angle),
      start.dy - (config.length * 0.6) * math.cos(config.angle),
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

    // Draw sub-branches for complexity
    if (config.length > 60) {
      _drawSubBranch(
        canvas,
        Offset(
          lerpDouble(start.dx, endPoint.dx, 0.6)!,
          lerpDouble(start.dy, endPoint.dy, 0.6)!,
        ),
        config.angle + (config.angle > 0 ? -0.5 : 0.5),
        config.length * 0.5,
        config.width * 0.6,
        config.leafCount ~/ 2,
        config.leafSize * 0.9,
      );
    }

    // Twigs
    for (int i = 0; i < config.twigCount; i++) {
      final twigT = 0.4 + (i * 0.2);
      final twigStart = Offset(
        lerpDouble(start.dx, endPoint.dx, twigT)!,
        lerpDouble(start.dy, endPoint.dy, twigT)!,
      );
      _drawSmallTwig(canvas, twigStart, config.angle, config.width * 0.5);
    }

    // Main leaf cluster
    drawLeafCluster(canvas, endPoint, config);
  }

  void _drawSubBranch(
    Canvas canvas,
    Offset start,
    double angle,
    double length,
    double width,
    int leafCount,
    double leafSize,
  ) {
    final endPoint = Offset(
      start.dx + length * math.sin(angle),
      start.dy - length * math.cos(angle),
    );

    final branchPaint = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader =
          LinearGradient(
            colors: [
              const Color(0xFF8D6E63),
              const Color(0xFFA1887F),
            ],
          ).createShader(
            Rect.fromPoints(start, endPoint),
          );

    canvas.drawLine(start, endPoint, branchPaint);

    // Leaves on sub-branch
    final random = math.Random(start.dx.toInt());
    for (int i = 0; i < leafCount; i++) {
      final leafAngle = angle + (random.nextDouble() - 0.5) * 2.5;
      final distance = 8 + random.nextDouble() * 18;
      final rustleX = math.sin(elapsedTime * math.pi * 2 + i * 0.7) * 2;
      final rustleY = math.cos(elapsedTime * math.pi * 1.5 + i * 0.5) * 1.5;

      final leafPos = Offset(
        endPoint.dx + math.cos(leafAngle) * distance + rustleX,
        endPoint.dy + math.sin(leafAngle) * distance + rustleY,
      );

      drawSingleLeaf(canvas, leafPos, leafSize, leafAngle, false);
    }
  }

  void _drawSmallTwig(
    Canvas canvas,
    Offset start,
    double baseAngle,
    double width,
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

    // Leaves on twig
    for (int i = 0; i < 3; i++) {
      final leafAngle = twigAngle + (random.nextDouble() - 0.5) * 2.0;
      final distance = 4 + random.nextDouble() * 8;
      final leafPos = Offset(
        twigEnd.dx + math.cos(leafAngle) * distance,
        twigEnd.dy + math.sin(leafAngle) * distance,
      );
      drawSingleLeaf(canvas, leafPos, 9, leafAngle, false);
    }
  }

  @override
  List<Color> getLeafColors() {
    return const [
      Color(0xFF7CB342),
      Color(0xFF689F38),
      Color(0xFF558B2F),
    ];
  }

  @override
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Gentle ambient particles
    _drawAmbientParticles(canvas, centerX, groundY, trunkHeight);
  }

  void _drawAmbientParticles(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
  ) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (elapsedTime * 0.3 + i * 0.8) % (math.pi * 2);
      final radius = 70 + (i % 3) * 20;
      final bobbing = math.sin(elapsedTime * 1.5 + i) * 12;

      final x = centerX + math.cos(angle) * radius;
      final y =
          groundY - height * 0.55 + math.sin(angle) * radius * 0.4 + bobbing;

      final pulse = (math.sin(elapsedTime * 3 + i * 1.2) + 1) / 2;
      final size = 1.5 + pulse * 1.5;

      particlePaint.color = const Color(
        0xFF7CB342,
      ).withValues(alpha: 0.3 * pulse);
      canvas.drawCircle(Offset(x, y), size, particlePaint);
    }
  }
}
