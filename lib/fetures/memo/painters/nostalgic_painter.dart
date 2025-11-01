import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Nostalgic Emotion - Orbiting butterflies
class NostalgicPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
    final random = math.Random(memory.id.hashCode);
    final orbitSpeed = 0.2 + (random.nextDouble() * 0.3);
    final progress = (ctx.elapsedTime * orbitSpeed + (index / total)) % 1.0;
    final angle = progress * math.pi * 2;

    // Adapt orbit to tree stage
    double maxRadius = ctx.trunkHeight * 0.4;
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

    _drawButterfly(ctx.canvas, Offset(x, y), ctx.elapsedTime, index);
  }

  void _drawButterfly(Canvas canvas, Offset position, double time, int index) {
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
