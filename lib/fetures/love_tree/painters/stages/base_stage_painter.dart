import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/branch_data.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/painters/ground_painter.dart';

/// Abstract base class for all tree stage painters
abstract class BaseTreeStagePainter {
  final double elapsedTime;
  final LoveTree tree;
  final GroundPainter groundPainter;
  final math.Random random;

  BaseTreeStagePainter({
    required this.elapsedTime,
    required this.tree,
  }) : groundPainter = GroundPainter(elapsedTime: elapsedTime),
       random = math.Random(1);

  /// Get the branch schema for this stage
  TreeBranchSchema get schema;

  /// Main paint method - template pattern
  void paint(Canvas canvas, Size size, double centerX, double groundY) {
    // 1. Paint ground
    groundPainter.paint(canvas, size, groundY);

    // 2. Calculate dimensions
    final trunkHeight = tree.height * schema.heightMultiplier;
    final trunkWidth =
        BranchSchemas.baseTrunkWidth * schema.trunkWidthMultiplier;
    final windSway = calculateWindSway();

    // 3. Paint special background effects (glow, etc.)
    paintBackgroundEffects(canvas, centerX, groundY, trunkHeight);

    // 4. Paint trunk
    paintTrunk(canvas, centerX, groundY, trunkHeight, trunkWidth, windSway);

    // 5. Paint branches with leaves
    paintBranches(canvas, centerX, groundY, trunkHeight, windSway);

    // 6. Paint foreground effects (sparkles, etc.)
    paintForegroundEffects(canvas, centerX, groundY, trunkHeight);
  }

  /// Calculate wind sway based on time
  double calculateWindSway() {
    return math.sin(elapsedTime * math.pi) * 2.5;
  }

  /// Background effects (override if needed)
  void paintBackgroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {
    // Default: draw glow if schema specifies
    if (schema.hasGlow) {
      _drawGlow(canvas, centerX, groundY, trunkHeight);
    }
  }

  /// Draw soft glow around tree
  void _drawGlow(Canvas canvas, double centerX, double groundY, double height) {
    final glowPulse = (math.sin(elapsedTime * math.pi * 2) + 1) / 2;
    final glowOpacity = 0.06 * glowPulse;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(
      Offset(centerX, groundY - height * 0.5),
      120,
      glowPaint,
    );
  }

  /// Abstract: Paint trunk (each stage customizes)
  void paintTrunk(
    Canvas canvas,
    double centerX,
    double groundY,
    double height,
    double width,
    double sway,
  );

  /// Paint all branches
  void paintBranches(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
    double windSway,
  ) {
    for (final branchConfig in schema.branches) {
      final y = groundY - trunkHeight * branchConfig.heightRatio;
      final branchSway = windSway * (1.0 - branchConfig.heightRatio);
      final startOffset = Offset(centerX + branchSway, y);

      paintSingleBranch(canvas, startOffset, branchConfig, trunkHeight);
    }
  }

  /// Paint a single branch with its leaves
  void paintSingleBranch(
    Canvas canvas,
    Offset start,
    BranchConfig config,
    double trunkHeight,
  ) {
    // Calculate end point
    final endPoint = Offset(
      start.dx + config.length * math.sin(config.angle),
      start.dy - config.length * math.cos(config.angle),
    );

    // Draw branch
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

    // Draw twigs
    for (int i = 0; i < config.twigCount; i++) {
      final twigT = 0.4 + (i * 0.2);
      final twigStart = Offset(
        lerpDouble(start.dx, endPoint.dx, twigT)!,
        lerpDouble(start.dy, endPoint.dy, twigT)!,
      );
      _drawSmallTwig(canvas, twigStart, config.angle, config.width * 0.5);
    }

    // Draw leaf cluster at end
    drawLeafCluster(canvas, endPoint, config);
  }

  /// Draw a small twig branching off
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

    // Small leaves on twig
    _drawMiniLeafCluster(canvas, twigEnd, 2, twigAngle);
  }

  /// Draw mini leaf cluster (for twigs)
  void _drawMiniLeafCluster(
    Canvas canvas,
    Offset center,
    int count,
    double baseAngle,
  ) {
    final random = math.Random(center.dx.toInt());
    for (int i = 0; i < count; i++) {
      final angle = baseAngle + (random.nextDouble() - 0.5) * 2.0;
      final distance = 4 + random.nextDouble() * 8;
      final leafPos = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      drawSingleLeaf(canvas, leafPos, 8, angle, false);
    }
  }

  /// Draw leaf cluster at branch end
  void drawLeafCluster(
    Canvas canvas,
    Offset center,
    BranchConfig config,
  ) {
    final random = math.Random(center.dx.toInt());
    for (int i = 0; i < config.leafCount; i++) {
      final angle = config.angle + (random.nextDouble() - 0.5) * 3.0;
      final distance = 8 + random.nextDouble() * 20;
      final rustleX = math.sin(elapsedTime * math.pi * 2 + i * 0.7) * 2;
      final rustleY = math.cos(elapsedTime * math.pi * 1.5 + i * 0.5) * 1.5;

      final leafPos = Offset(
        center.dx + math.cos(angle) * distance + rustleX,
        center.dy + math.sin(angle) * distance + rustleY,
      );

      final isGolden = schema.stage == TreeStage.radiant && i % 5 == 0;
      drawSingleLeaf(
        canvas,
        leafPos,
        config.leafSize,
        angle,
        isGolden,
      );
    }
  }

  /// Draw a single leaf
  void drawSingleLeaf(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
    bool isGolden,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final leafPaint = Paint()..style = PaintingStyle.fill;

    if (isGolden) {
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
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(-size * 0.5, -size * 0.5, size, size));
    } else {
      leafPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: getLeafColors(),
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(-size * 0.5, -size * 0.5, size, size));
    }

    // Leaf shape
    final path = Path()
      ..moveTo(0, -size * 0.5)
      ..quadraticBezierTo(size * 0.4, -size * 0.25, size * 0.48, 0)
      ..quadraticBezierTo(size * 0.4, size * 0.25, 0, size * 0.5)
      ..quadraticBezierTo(-size * 0.4, size * 0.25, -size * 0.48, 0)
      ..quadraticBezierTo(-size * 0.4, -size * 0.25, 0, -size * 0.5);

    canvas.drawPath(path, leafPaint);

    // Vein
    final veinPaint = Paint()
      ..color = isGolden
          ? const Color(0xFFDAA520).withValues(alpha: 0.4)
          : const Color(0xFF558B2F).withValues(alpha: 0.3)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, -size * 0.4),
      Offset(0, size * 0.4),
      veinPaint,
    );

    canvas.restore();
  }

  /// Foreground effects (override if needed)
  void paintForegroundEffects(
    Canvas canvas,
    double centerX,
    double groundY,
    double trunkHeight,
  ) {}

  /// Get branch colors (override for stage variations)
  List<Color> getBranchColors() {
    return const [
      Color(0xFF6D4C41),
      Color(0xFF8D6E63),
      Color(0xFFA1887F),
    ];
  }

  /// Get leaf colors (override for stage variations)
  List<Color> getLeafColors() {
    return const [
      Color(0xFF9CCC65),
      Color(0xFF7CB342),
      Color(0xFF558B2F),
    ];
  }
}
