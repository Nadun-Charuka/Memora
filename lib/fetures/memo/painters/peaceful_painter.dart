import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'animation_context.dart';
import 'base_emotion_painter.dart';

/// Peaceful Emotion - Jumping rabbits on the ground
class PeacefulPainter extends BaseEmotionPainter {
  @override
  void paintSingle(
    AnimationContext ctx,
    Memory memory,
    int index,
    int total,
  ) {
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
    _drawRabbit(ctx.canvas, Offset(x, y), ctx.elapsedTime, index);
  }

  void _drawRabbit(Canvas canvas, Offset position, double time, int index) {
    const iconSize = 15.0;
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);

    final breathe = 1.0 + math.sin(time * math.pi * 1.5) * 0.05;
    canvas.scale(breathe);

    // Body (tummy)
    paint.color = Colors.white;
    canvas.drawCircle(Offset(0, iconSize * 0.2), iconSize * 0.4, paint);

    // Head
    canvas.drawCircle(Offset(0, -iconSize * 0.3), iconSize * 0.28, paint);

    // Ears with twitch
    final earTwitch = math.sin(time * math.pi * 3 + index) * 0.1;

    // Left ear
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
    // Inner ear (pink)
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

    // Right ear
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
    // Inner ear (pink)
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

    // Eyes
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

    // Nose with twitch
    final noseTwitch = math.sin(time * math.pi * 4) * 0.02;
    paint.color = const Color(0xFFFFB6C1);
    canvas.drawCircle(
      Offset(noseTwitch, -iconSize * 0.22),
      iconSize * 0.05,
      paint,
    );

    // Mouth
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

    // Whiskers
    paint.strokeWidth = 0.8;
    // Left whiskers
    canvas.drawLine(
      Offset(-iconSize * 0.1, -iconSize * 0.22),
      Offset(-iconSize * 0.3, -iconSize * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(-iconSize * 0.1, -iconSize * 0.22),
      Offset(-iconSize * 0.3, -iconSize * 0.19),
      paint,
    );
    // Right whiskers
    canvas.drawLine(
      Offset(iconSize * 0.1, -iconSize * 0.22),
      Offset(iconSize * 0.3, -iconSize * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(iconSize * 0.1, -iconSize * 0.22),
      Offset(iconSize * 0.3, -iconSize * 0.19),
      paint,
    );

    paint.style = PaintingStyle.fill;

    // Fluffy tail
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(iconSize * 0.35, iconSize * 0.25),
      iconSize * 0.15,
      paint,
    );

    canvas.restore();
  }
}
