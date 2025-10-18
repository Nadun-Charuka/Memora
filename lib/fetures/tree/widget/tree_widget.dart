import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:memora/fetures/tree/model/love_tree.dart';

class TreeWidget extends StatefulWidget {
  final LoveTree tree;

  const TreeWidget({required this.tree, super.key});

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (widget.tree.mood == TreeMood.thriving)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 250 + (_controller.value * 20),
                height: 250 + (_controller.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.pink.withOpacity(0.3 * _controller.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

        // Tree based on stage
        _buildTreeForStage(widget.tree.stage),

        // Particles
        if (widget.tree.mood == TreeMood.happy ||
            widget.tree.mood == TreeMood.thriving)
          _buildParticles(),
      ],
    );
  }

  Widget _buildTreeForStage(TreeStage stage) {
    // Use different Lottie animations or custom drawings
    String animation;

    switch (stage) {
      case TreeStage.seedling:
        animation = 'assets/animations/seedling.json';
        break;
      case TreeStage.growing:
        animation = 'assets/animations/growing_tree.json';
        break;
      case TreeStage.blooming:
        animation = 'assets/animations/blooming_tree.json';
        break;
      case TreeStage.mature:
        animation = 'assets/animations/mature_tree.json';
        break;
      case TreeStage.withering:
        animation = 'assets/animations/withering_tree.json';
        break;
    }

    return SizedBox(
      width: 200 + (widget.tree.level * 10),
      height: 200 + (widget.tree.level * 10),
      child: Lottie.asset(
        animation,
        fit: BoxFit.contain,
        // For placeholder, use a simple tree illustration
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderTree(stage);
        },
      ),
    );
  }

  Widget _buildPlaceholderTree(TreeStage stage) {
    // Fallback visual tree
    return CustomPaint(
      painter: TreePainter(
        stage: stage,
        height: widget.tree.height,
        health: widget.tree.health,
      ),
    );
  }

  Widget _buildParticles() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          'assets/animations/particles.json',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Custom tree painter for fallback
class TreePainter extends CustomPainter {
  final TreeStage stage;
  final double height;
  final double health;

  TreePainter({
    required this.stage,
    required this.height,
    required this.health,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(health)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Draw trunk
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, size.height - (height * 2)),
      paint,
    );

    // Draw branches based on stage
    if (stage != TreeStage.seedling) {
      paint.color = Colors.green.withOpacity(health);
      paint.strokeWidth = 4;

      // Simple branch pattern
      for (int i = 0; i < (stage.index + 1) * 3; i++) {
        final angle = (i * 60) * (3.14159 / 180);
        final branchLength = 30.0 + (stage.index * 10);
        canvas.drawLine(
          Offset(size.width / 2, size.height - 50 - (i * 15)),
          Offset(
            size.width / 2 + (branchLength * (i.isEven ? 1 : -1)),
            size.height - 70 - (i * 15),
          ),
          paint,
        );
      }
    }

    // Draw leaves/flowers
    if (stage == TreeStage.blooming || stage == TreeStage.mature) {
      paint.style = PaintingStyle.fill;
      paint.color = Colors.pink.withOpacity(health);

      for (int i = 0; i < 12; i++) {
        canvas.drawCircle(
          Offset(
            size.width / 2 + ((i % 3 - 1) * 40),
            size.height - 60 - ((i ~/ 3) * 25),
          ),
          6,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) => true;
}
