import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Love Emotion - Floating hearts with physics
class LovePainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final random = math.Random(memory.id.hashCode);

    // Emission point
    double yCenter;
    Offset originPoint;

    if (ctx.treeStructure != null && ctx.treeStructure!.branches.isNotEmpty) {
      yCenter = ctx.trunkHeight * 0.9;
      originPoint = Offset(ctx.centerX, ctx.groundY - yCenter);
    } else {
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

    // Sparkles
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
