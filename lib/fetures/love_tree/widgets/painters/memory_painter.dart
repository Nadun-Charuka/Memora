// ============================================================================
// ENHANCED MEMORY PAINTER - Tree-Aware Architecture
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';

// ============================================================================
// TREE STRUCTURE INFO - Provides branch positions for each stage
// ============================================================================
class TreeStructureInfo {
  final TreeStage stage;
  final double trunkHeight;
  final double trunkWidth;
  final List<BranchInfo> branches;

  TreeStructureInfo({
    required this.stage,
    required this.trunkHeight,
    required this.trunkWidth,
    required this.branches,
  });

  // Get suitable attachment points for memories
  List<Offset> getMemoryPoints(Offset treeBase, int count) {
    if (branches.isEmpty) {
      // For seedling, use positions along the stem
      return List.generate(count, (i) {
        final t = (i + 1) / (count + 1);
        return Offset(
          treeBase.dx,
          treeBase.dy - trunkHeight * t,
        );
      });
    }

    // Use branch endpoints and midpoints
    final points = <Offset>[];
    for (final branch in branches) {
      points.add(branch.endPoint);
      if (branch.length > 50) {
        // Add midpoint for longer branches
        points.add(branch.midPoint);
      }
    }
    return points;
  }
}

class BranchInfo {
  final Offset startPoint;
  final Offset endPoint;
  final double angle;
  final double length;

  BranchInfo({
    required this.startPoint,
    required this.endPoint,
    required this.angle,
    required this.length,
  });

  Offset get midPoint => Offset(
    (startPoint.dx + endPoint.dx) / 2,
    (startPoint.dy + endPoint.dy) / 2,
  );
}

// ============================================================================
// ENHANCED ANIMATION CONTEXT - Now includes tree structure
// ============================================================================
class AnimationContext {
  final Canvas canvas;
  final Size size;
  final double centerX;
  final double groundY;
  final double elapsedTime;
  final LoveTree tree;
  final TreeStructureInfo? treeStructure; // NEW!

  AnimationContext({
    required this.canvas,
    required this.size,
    required this.centerX,
    required this.groundY,
    required this.elapsedTime,
    required this.tree,
    this.treeStructure,
  });

  double get trunkHeight {
    return tree.height *
        (tree.stage == TreeStage.seedling
            ? 2.0
            : tree.stage == TreeStage.growing
            ? 1.5
            : tree.stage == TreeStage.blooming
            ? 1.2
            : 1.0);
  }
}

// ============================================================================
// MAIN PAINTER - Now tree-structure aware
// ============================================================================
class MemoryPainter {
  final double elapsedTime;
  final LoveTree tree;
  final List<Memory> memories;
  late final Map<MemoryEmotion, EmotionAnimator> _animators;

  MemoryPainter({
    required this.elapsedTime,
    required this.tree,
    required this.memories,
  }) {
    _animators = {
      MemoryEmotion.happy: HappyAnimator(),
      MemoryEmotion.excited: ExcitedAnimator(),
      MemoryEmotion.joyful: JoyfulAnimator(),
      MemoryEmotion.grateful: GratefulAnimator(),
      MemoryEmotion.love: LoveAnimator(),
      MemoryEmotion.sad: SadAnimator(),
      MemoryEmotion.nostalgic: NostalgicAnimator(),
      MemoryEmotion.peaceful: PeacefulAnimator(),
      MemoryEmotion.awful: AwfulAnimator(),
    };
  }

  void paint(
    Canvas canvas,
    Size size,
    double centerX,
    double groundY, {
    TreeStructureInfo? treeStructure,
  }) {
    if (memories.isEmpty) return;

    final context = AnimationContext(
      canvas: canvas,
      size: size,
      centerX: centerX,
      groundY: groundY,
      elapsedTime: elapsedTime,
      tree: tree,
      treeStructure: treeStructure, // Pass structure info!
    );

    final groupedMemories = <MemoryEmotion, List<Memory>>{};
    for (var emotion in MemoryEmotion.values) {
      groupedMemories[emotion] = memories
          .where((m) => m.emotion == emotion)
          .toList();
    }

    for (var entry in groupedMemories.entries) {
      if (entry.value.isEmpty) continue;
      final animator = _animators[entry.key]!;
      animator.paintAll(context, entry.value);
    }
  }
}

// ============================================================================
// BASE ANIMATOR
// ============================================================================
abstract class EmotionAnimator {
  void paintAll(AnimationContext ctx, List<Memory> memories) {
    for (int i = 0; i < memories.length; i++) {
      paintSingle(ctx, memories[i], i, memories.length);
    }
  }

  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  );
}

// ============================================================================
// 🌸 HAPPY ANIMATOR - Flowers on tree branches (TREE-AWARE!)
// ============================================================================
class HappyAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final random = math.Random(memory.id.hashCode);

    // Use tree structure if available
    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      final branches = ctx.treeStructure!.branches;
      final branchIndex = index % branches.length;
      final branch = branches[branchIndex];

      // Position along the branch
      final t = 0.7 + random.nextDouble() * 0.3; // Near branch end
      final x =
          branch.startPoint.dx +
          (branch.endPoint.dx - branch.startPoint.dx) * t;
      final y =
          branch.startPoint.dy +
          (branch.endPoint.dy - branch.startPoint.dy) * t;

      final sway = math.sin(ctx.elapsedTime * 2 + index) * 3;
      _drawFlower(ctx.canvas, Offset(x + sway, y), ctx.elapsedTime);
    } else {
      // Fallback for seedling stage
      final angle = (index / total) * math.pi * 2;
      final radius = ctx.trunkHeight * 0.2; // Scale with tree

      final x = ctx.centerX + math.cos(angle) * radius;
      final y = ctx.groundY - ctx.trunkHeight * 0.7;

      final sway = math.sin(ctx.elapsedTime * 2 + index) * 2;
      _drawFlower(ctx.canvas, Offset(x + sway, y), ctx.elapsedTime);
    }
  }

  void _drawFlower(Canvas canvas, Offset position, double time) {
    const iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    final scale = 1.0 + math.sin(time * math.pi * 2) * 0.1;
    canvas.scale(scale);

    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate(i * math.pi * 2 / 5);
      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          iconSize * 0.2,
          -iconSize * 0.25,
          0,
          -iconSize * 0.45,
        )
        ..quadraticBezierTo(-iconSize * 0.2, -iconSize * 0.25, 0, 0);
      paint.color = Color.lerp(
        const Color(0xFFFFB6C1),
        const Color(0xFFFF69B4),
        (i % 2 == 0) ? 0.7 : 1.0,
      )!;
      canvas.drawPath(petalPath, paint);
      canvas.restore();
    }

    paint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, iconSize * 0.15, paint);
    paint.color = const Color(0xFFFFA500);
    canvas.drawCircle(Offset.zero, iconSize * 0.08, paint);
    canvas.restore();
  }
}

// ============================================================================
// 🐦 EXCITED ANIMATOR - Flying birds WITH PROPER WINGS!
// ============================================================================
class ExcitedAnimator extends EmotionAnimator {
  static final _colorPalettes = [
    [
      Color(0xFF4A90E2),
      Color(0xFF87CEEB),
      Color(0xFF4A90E2),
      Color(0xFFF5A623),
    ],
    [
      Color(0xFFD0021B),
      Color(0xFFFF6347),
      Color(0xFFD0021B),
      Color(0xFFE27A3F),
    ],
    [
      Color(0xFF417505),
      Color(0xFF7ED321),
      Color(0xFF417505),
      Color(0xFFB8E986),
    ],
    [
      Color(0xFF9013FE),
      Color(0xFFBD10E0),
      Color(0xFF9013FE),
      Color(0xFFFFD700),
    ],
    [
      Color(0xFFF5A623),
      Color(0xFFF8E71C),
      Color(0xFFF5A623),
      Color(0xFFE27A3F),
    ],
  ];

  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final palette = _colorPalettes[index % _colorPalettes.length];
    final isFlyingRight = index % 2 == 0;

    final birdSpeed = 0.3 + (index * 0.2);
    final progress = (ctx.elapsedTime * birdSpeed + (index / total)) % 1.0;

    final x = isFlyingRight
        ? ctx.size.width * progress
        : ctx.size.width * (1.0 - progress);

    final pathVariation = (index % 3) * 2.0;
    final y =
        60.0 +
        (index * 35) +
        math.sin(progress * math.pi * 4 + pathVariation) * 20 +
        math.sin(ctx.elapsedTime * math.pi * 2 + index) * 8;

    _drawBird(
      ctx.canvas,
      Offset(x, y),
      ctx.elapsedTime,
      index,
      palette,
      isFlyingRight,
    );
  }

  void _drawBird(
    Canvas canvas,
    Offset position,
    double time,
    int index,
    List<Color> palette,
    bool facingRight,
  ) {
    const baseSize = 18.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final tilt = math.sin(time * math.pi * 2 + index) * 0.1;
    canvas.rotate(tilt);
    if (!facingRight) canvas.scale(-1.0, 1.0);

    // WING FLAP ANIMATION
    final wingFlap = math.sin(time * math.pi * 12 + index * 0.5) * 0.6;
    final bodyScale = 1.0 + wingFlap.abs() * 0.08;
    canvas.scale(bodyScale, 1.0);

    // Body with gradient
    paint.shader =
        LinearGradient(
          colors: [palette[0], palette[1]],
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
      )
      ..quadraticBezierTo(
        -baseSize * 0.55,
        baseSize * 0.2,
        -baseSize * 0.3,
        baseSize * 0.25,
      )
      ..quadraticBezierTo(baseSize * 0.2, baseSize * 0.25, baseSize * 0.4, 0)
      ..quadraticBezierTo(baseSize * 0.2, -baseSize * 0.25, -baseSize * 0.3, 0)
      ..close();
    canvas.drawPath(bodyPath, paint);
    paint.shader = null;

    // Head
    paint.color = palette[1];
    canvas.drawCircle(
      Offset(baseSize * 0.35, -baseSize * 0.05),
      baseSize * 0.2,
      paint,
    );

    // Eye
    paint.color = Colors.black.withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(baseSize * 0.45, -baseSize * 0.1),
      baseSize * 0.04,
      paint,
    );

    // Beak
    paint.color = palette[3];
    final beakPath = Path()
      ..moveTo(baseSize * 0.48, -baseSize * 0.05)
      ..lineTo(baseSize * 0.65, 0)
      ..lineTo(baseSize * 0.48, baseSize * 0.05)
      ..close();
    canvas.drawPath(beakPath, paint);

    // ✨ WINGS - THE MISSING PIECE!
    canvas.scale(1.0 / bodyScale, 1.0); // Reset body scale
    paint.color = palette[2];

    final wingBaseAngle = -0.6;

    // Top wing
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05);
    canvas.rotate(wingBaseAngle + wingFlap);
    _drawWing(canvas, baseSize, paint);
    canvas.restore();

    // Bottom wing (mirrored)
    canvas.save();
    canvas.translate(-baseSize * 0.2, -baseSize * 0.05);
    canvas.rotate(-(wingBaseAngle + wingFlap));
    canvas.scale(1, -1);
    _drawWing(canvas, baseSize, paint);
    canvas.restore();

    canvas.scale(bodyScale, 1.0); // Restore body scale

    // Tail feathers
    paint.color = palette[0].withValues(alpha: 0.9);
    final tailPath = Path()
      ..moveTo(-baseSize * 0.45, 0)
      ..lineTo(-baseSize * 0.65, -baseSize * 0.1)
      ..lineTo(-baseSize * 0.55, 0)
      ..lineTo(-baseSize * 0.65, baseSize * 0.1)
      ..close();
    canvas.drawPath(tailPath, paint);

    canvas.restore();
  }

  void _drawWing(Canvas canvas, double baseSize, Paint paint) {
    final wingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        baseSize * 0.3,
        -baseSize * 0.4,
        baseSize * 0.8,
        -baseSize * 0.3,
      )
      ..quadraticBezierTo(baseSize * 0.5, -baseSize * 0.1, baseSize * 0.4, 0)
      ..close();
    canvas.drawPath(wingPath, paint);

    // Wing detail lines
    paint.color = Colors.black.withValues(alpha: 0.2);
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
    paint.style = PaintingStyle.fill;
  }
}

// ============================================================================
// 🍎 JOYFUL ANIMATOR - Hanging fruits (TREE-AWARE!)
// ============================================================================
class JoyfulAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    // Use tree structure if available
    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      final branches = ctx.treeStructure!.branches;
      final branchIndex = index % branches.length;
      final branch = branches[branchIndex];

      // Hang from branch end
      final x = branch.endPoint.dx;
      final y = branch.endPoint.dy + 15; // Hang below branch

      final swing = math.sin(ctx.elapsedTime * math.pi * 2 + index) * 3;
      _drawFruit(ctx.canvas, Offset(x + swing, y));
    } else {
      // Fallback for seedling
      final angle = (index / total) * math.pi * 2;
      final radius = ctx.trunkHeight * 0.15;
      final x = ctx.centerX + math.cos(angle) * radius;
      final y = ctx.groundY - ctx.trunkHeight * 0.8;
      final swing = math.sin(ctx.elapsedTime * math.pi * 2 + index) * 2;
      _drawFruit(ctx.canvas, Offset(x + swing, y));
    }
  }

  void _drawFruit(Canvas canvas, Offset position) {
    const iconSize = 15.0;
    canvas.save();
    canvas.translate(position.dx, position.dy);

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

    // Fruit body
    final fruitPaint = Paint()
      ..color = const Color(0xFFFF6347)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, iconSize * 0.45, fruitPaint);

    // Highlight
    fruitPaint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.15),
      iconSize * 0.15,
      fruitPaint,
    );

    // Leaf
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
}

// Continue with other animators (GratefulAnimator, LoveAnimator, etc.)
// following the same tree-aware pattern...

// For brevity, I'll show the pattern for one more:

// ============================================================================
// 🦋 NOSTALGIC ANIMATOR - Orbiting butterflies (TREE-AWARE!)
// ============================================================================
class NostalgicAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final random = math.Random(memory.id.hashCode);
    final orbitSpeed = 0.2 + (random.nextDouble() * 0.3);
    final progress = (ctx.elapsedTime * orbitSpeed + (index / total)) % 1.0;
    final angle = progress * math.pi * 2;

    // Adapt orbit to tree stage
    double maxRadius = ctx.trunkHeight * 0.4; // Scale with tree!
    double yCenter = ctx.trunkHeight * 0.6;

    if (ctx.tree.stage == TreeStage.seedling) {
      maxRadius = ctx.trunkHeight * 0.2;
      yCenter = ctx.trunkHeight * 0.5;
    } else if (ctx.tree.stage == TreeStage.growing) {
      maxRadius = ctx.trunkHeight * 0.3;
    }

    final orbitRadius = maxRadius * (0.5 + random.nextDouble() * 0.5);
    final waveFreq = 3.0 + random.nextDouble() * 3.0;
    final waveAmp = 15.0 + random.nextDouble() * 20.0;
    final radiusVariation =
        math.sin(progress * math.pi * 2.5) * (maxRadius * 0.2);

    final x =
        ctx.centerX +
        math.cos(angle) * (orbitRadius + radiusVariation) +
        math.sin(progress * math.pi * waveFreq) * 10;
    final y =
        ctx.groundY -
        yCenter +
        math.sin(angle) * orbitRadius * 0.5 +
        math.sin(progress * math.pi * waveFreq) * waveAmp;

    _drawButterfly(ctx.canvas, Offset(x, y), ctx.elapsedTime);
  }

  void _drawButterfly(Canvas canvas, Offset position, double time) {
    const iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;
    final flutter = math.sin(time * math.pi * 6) * 0.3;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    paint.color = const Color(0xFFBA55D3);

    // Wings with flutter
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

    // Wing highlights
    paint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.4);
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
        center: Offset.zero,
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

    canvas.restore();
  }
}

// ============================================================================
// ⭐ GRATEFUL ANIMATOR - Twinkling stars
// ============================================================================
class GratefulAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final y = 40.0 + (index % 3) * 30;
    _drawStar(ctx.canvas, Offset(x, y), ctx.elapsedTime, index);
  }

  void _drawStar(Canvas canvas, Offset position, double time, int index) {
    const iconSize = 15.0;
    final twinkle = (math.sin(time * math.pi * 4 + index * 2) + 1) / 2;
    final scale = 0.7 + twinkle * 0.6;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);

    final paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.8 + twinkle * 0.2)
      ..style = PaintingStyle.fill;

    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * math.pi * 2 / 5) - math.pi / 2;
      final outerRadius = iconSize * 0.5;
      final innerRadius = iconSize * 0.2;

      if (i == 0) {
        starPath.moveTo(
          math.cos(angle) * outerRadius,
          math.sin(angle) * outerRadius,
        );
      } else {
        starPath.lineTo(
          math.cos(angle) * outerRadius,
          math.sin(angle) * outerRadius,
        );
      }

      final innerAngle = angle + (math.pi / 5);
      starPath.lineTo(
        math.cos(innerAngle) * innerRadius,
        math.sin(innerAngle) * innerRadius,
      );
    }
    starPath.close();
    canvas.drawPath(starPath, paint);

    paint
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3 * twinkle)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(starPath, paint);
    canvas.restore();
  }
}

// ============================================================================
// ❤️ LOVE ANIMATOR - Floating hearts with physics (TREE-AWARE!)
// ============================================================================
class LoveAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final random = math.Random(memory.id.hashCode);

    // Determine emission point based on tree structure
    double yCenter;
    Offset originPoint;

    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      // Emit from top of tree
      yCenter = ctx.trunkHeight * 0.9;
      originPoint = Offset(ctx.centerX, ctx.groundY - yCenter);
    } else {
      // Emit from seedling top
      yCenter = ctx.trunkHeight * 0.7;
      originPoint = Offset(ctx.centerX, ctx.groundY - yCenter);
    }

    final cycleDuration = 6.0 + random.nextDouble() * 4.0;
    final lifeProgress =
        (ctx.elapsedTime / cycleDuration + (index / total)) % 1.0;

    // Reset in last 20%
    if (lifeProgress > 0.8) {
      _drawHeart(ctx.canvas, originPoint, ctx.elapsedTime);
      return;
    }

    final time = lifeProgress * cycleDuration * 0.8;
    final angle = random.nextDouble() * math.pi * 2;

    double maxSpeed = 160.0;
    if (ctx.tree.stage == TreeStage.seedling) {
      maxSpeed = 80.0;
    } else if (ctx.tree.stage == TreeStage.growing) {
      maxSpeed = 120.0;
    }

    final initialSpeed = maxSpeed * (0.2 + random.nextDouble() * 0.8);
    final vx = math.cos(angle) * initialSpeed;
    final vy = math.sin(angle) * initialSpeed;
    const gravity = 40.0;

    final x = originPoint.dx + vx * time;
    final y = originPoint.dy + vy * time + 0.5 * gravity * time * time;

    if (y < ctx.size.height && x > 0 && x < ctx.size.width) {
      _drawHeart(ctx.canvas, Offset(x, y), ctx.elapsedTime);
    }
  }

  void _drawHeart(Canvas canvas, Offset position, double time) {
    const iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final heartBeat = 1.0 + math.sin(time * math.pi * 4) * 0.15;
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

    paint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.8);
    final sparkleAngle = time * math.pi * 4;
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + sparkleAngle;
      final sparkleOffset = Offset(
        math.cos(angle) * iconSize * 0.8,
        math.sin(angle) * iconSize * 0.8,
      );
      canvas.drawCircle(sparkleOffset, iconSize * 0.08, paint);
    }

    canvas.restore();
  }
}

// ============================================================================
// 💧 SAD ANIMATOR - Falling raindrops
// ============================================================================
class SadAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final fallSpeed = 0.5 + (index * 0.15);
    final progress = (ctx.elapsedTime * fallSpeed) % 1.0;

    final startY = ctx.size.height * 0.1;
    final endY = ctx.size.height * 0.85;
    final y = startY + ((endY - startY) * progress);

    final drift = math.sin(progress * math.pi * 3) * 10;
    _drawRaindrop(ctx.canvas, Offset(x + drift, y), progress);
  }

  void _drawRaindrop(Canvas canvas, Offset position, double progress) {
    const iconSize = 8.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final opacity = 0.5 + (progress * 0.4);
    paint.color = const Color(0xFF4682B4).withValues(alpha: opacity);

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

    paint.color = Colors.white.withValues(alpha: 0.5 * opacity);
    canvas.drawCircle(
      Offset(-iconSize * 0.15, -iconSize * 0.4),
      iconSize * 0.18,
      paint,
    );

    if (progress > 0.92) {
      final splashProgress = (progress - 0.92) / 0.08;
      final splashSize = splashProgress * iconSize * 1.5;
      paint.color = const Color(
        0xFF4682B4,
      ).withValues(alpha: 0.4 * (1 - splashProgress));

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
}

// ============================================================================
// 🐰 PEACEFUL ANIMATOR - Jumping rabbits
// ============================================================================
class PeacefulAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final uniqueSeed = index * 1000 + (memory.id.hashCode % 1000);
    final random = math.Random(uniqueSeed);

    final spacing = ctx.size.width * 0.08;
    final totalWidth = spacing * (total - 1);
    final startX = ctx.centerX - (totalWidth / 2);
    final baseX = startX + (spacing * index);
    final randomOffsetX = (random.nextDouble() - 0.5) * 15;

    const iconSize = 15.0;
    final x = math.max(
      iconSize,
      math.min(ctx.size.width - iconSize, baseX + randomOffsetX),
    );

    final jumpSpeed = 1.5 + (random.nextDouble() * 2.5);
    final jumpProgress = (ctx.elapsedTime * jumpSpeed + (index * 0.2)) % 1.0;
    final jumpHeight = math.sin(jumpProgress * math.pi) * 12.0;

    final y = ctx.groundY - jumpHeight - 10;
    _drawRabbit(ctx.canvas, Offset(x, y), ctx.elapsedTime);
  }

  void _drawRabbit(Canvas canvas, Offset position, double time) {
    const iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final breathe = 1.0 + math.sin(time * math.pi * 1.5) * 0.05;
    canvas.scale(breathe);

    // Tummy & Head
    paint.color = Colors.white;
    canvas.drawCircle(Offset(0, iconSize * 0.2), iconSize * 0.4, paint);
    canvas.drawCircle(Offset(0, -iconSize * 0.3), iconSize * 0.28, paint);

    // Ears
    final earTwitch = math.sin(time * math.pi * 3) * 0.1;

    canvas.save();
    canvas.translate(-iconSize * 0.15, -iconSize * 0.5);
    canvas.rotate(-0.2 + earTwitch);
    paint.color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: iconSize * 0.18,
        height: iconSize * 0.4,
      ),
      paint,
    );
    paint.color = const Color(0xFFFFB6C1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, iconSize * 0.05),
        width: iconSize * 0.1,
        height: iconSize * 0.28,
      ),
      paint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(iconSize * 0.15, -iconSize * 0.5);
    canvas.rotate(0.2 - earTwitch);
    paint.color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: iconSize * 0.18,
        height: iconSize * 0.4,
      ),
      paint,
    );
    paint.color = const Color(0xFFFFB6C1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, iconSize * 0.05),
        width: iconSize * 0.1,
        height: iconSize * 0.28,
      ),
      paint,
    );
    canvas.restore();

    // Eyes, Nose, Mouth
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(-iconSize * 0.1, -iconSize * 0.32),
      iconSize * 0.05,
      paint,
    );
    canvas.drawCircle(
      Offset(iconSize * 0.1, -iconSize * 0.32),
      iconSize * 0.05,
      paint,
    );

    final noseTwitch = math.sin(time * math.pi * 4) * 0.02;
    paint.color = const Color(0xFFFFB6C1);
    canvas.drawCircle(
      Offset(noseTwitch, -iconSize * 0.22),
      iconSize * 0.05,
      paint,
    );

    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -iconSize * 0.22),
      Offset(0, -iconSize * 0.16),
      paint,
    );
    canvas.drawLine(
      Offset(0, -iconSize * 0.16),
      Offset(-iconSize * 0.08, -iconSize * 0.12),
      paint,
    );
    canvas.drawLine(
      Offset(0, -iconSize * 0.16),
      Offset(iconSize * 0.08, -iconSize * 0.12),
      paint,
    );
    paint.style = PaintingStyle.fill;

    canvas.restore();
  }
}

// ============================================================================
// ⛈️ AWFUL ANIMATOR - Storm clouds with lightning
// ============================================================================
class AwfulAnimator extends EmotionAnimator {
  @override
  void paintSingle(AnimationContext ctx, Memory memory, int index, int total) {
    final random = math.Random(memory.id.hashCode);
    final cloudScale = 0.4 + random.nextDouble() * 0.4;
    final x = (ctx.size.width / (total + 1)) * (index + 1);
    final y = 70.0 + random.nextDouble() * 50.0;

    _drawStormCloud(
      ctx.canvas,
      Offset(x, y),
      ctx.elapsedTime,
      cloudScale,
      random,
    );
  }

  void _drawStormCloud(
    Canvas canvas,
    Offset position,
    double time,
    double cloudScale,
    math.Random random,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;
    final lightningFlash = (time * 2 + random.nextDouble() * 3.0) % 3.0;
    final isLightning = lightningFlash < 0.2;
    final drift = isLightning
        ? math.sin(time * math.pi * 40) * 3
        : math.sin(time * 0.5) * 50;

    canvas.save();
    canvas.translate(position.dx + drift, position.dy);

    final shadowPaint = Paint()
      ..color = const Color(0xFF2D3748).withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * cloudScale);
    canvas.drawCircle(Offset.zero, 40 * cloudScale, shadowPaint);

    canvas.scale(cloudScale);
    paint.color = const Color(0xFF4A5568).withValues(alpha: 0.7);
    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);
    canvas.drawCircle(const Offset(32, -3), 23, paint);
    canvas.drawCircle(const Offset(45, 2), 19, paint);
    canvas.drawCircle(const Offset(20, 6), 20, paint);
    canvas.drawCircle(const Offset(28, 8), 17, paint);

    paint.color = const Color(0xFF2D3748).withValues(alpha: 0.3);
    canvas.drawCircle(const Offset(-12, 3), 18, paint);
    canvas.drawCircle(const Offset(0, -2), 22, paint);
    canvas.drawCircle(const Offset(15, -8), 26, paint);

    canvas.scale(1.0 / cloudScale);

    if (isLightning) {
      final boltPaint = Paint()
        ..color = const Color(0xFFFFFACD).withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final lightningPath = Path()
        ..moveTo(15, 8)
        ..lineTo(20, 25)
        ..lineTo(15, 25)
        ..lineTo(22, 45)
        ..lineTo(17, 45)
        ..lineTo(25, 65);

      canvas.drawPath(lightningPath, boltPaint);

      boltPaint
        ..color = const Color(0xFFFFFF00).withValues(alpha: 0.4)
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(lightningPath, boltPaint);

      canvas.scale(cloudScale);
      paint
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.15)
        ..maskFilter = null;
      canvas.drawCircle(const Offset(15, -8), 26, paint);
      canvas.drawCircle(const Offset(32, -3), 23, paint);
    }

    canvas.restore();
  }
}
