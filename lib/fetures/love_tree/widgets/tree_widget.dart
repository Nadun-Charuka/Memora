import 'package:flutter/material.dart';
import 'package:memora/models/tree_model.dart';
import 'tree_painter.dart';

class TreeWidget extends StatefulWidget {
  final LoveTree tree;
  final List<Memory> memories;
  final VoidCallback? onMemoryTap;

  const TreeWidget({
    super.key,
    required this.tree,
    required this.memories,
    this.onMemoryTap,
  });

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onMemoryTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF87CEEB), // Sky blue
              const Color(0xFFE0F6FF), // Light blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Clouds
            if (widget.tree.isPlanted) ..._buildClouds(),

            // Sun
            if (widget.tree.isPlanted)
              Positioned(
                top: 40,
                right: 40,
                child: _buildSun(),
              ),

            // Tree
            Center(
              child: CustomPaint(
                size: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height * 0.4,
                ),
                painter: TreePainter(
                  tree: widget.tree,
                  memories: widget.memories,
                  animation: _animationController,
                ),
              ),
            ),

            // Tree info overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildTreeInfo(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildClouds() {
    return [
      Positioned(
        top: 60,
        left: 30,
        child: _buildCloud(60, 0.7),
      ),
      Positioned(
        top: 100,
        right: 50,
        child: _buildCloud(80, 0.6),
      ),
      Positioned(
        top: 150,
        left: 120,
        child: _buildCloud(50, 0.8),
      ),
    ];
  }

  Widget _buildCloud(double size, double opacity) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSun() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stage name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.tree.stage.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7C59),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9B78),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level ${widget.tree.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          if (widget.tree.isPlanted) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Growth Progress',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${widget.tree.memoryCount} memories',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B9B78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: widget.tree.stageProgress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6B9B78),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  '💚',
                  'Health',
                  '${(widget.tree.health * 100).toInt()}%',
                ),
                _buildStat(
                  '😊',
                  'Happiness',
                  '${(widget.tree.happiness * 100).toInt()}%',
                ),
                _buildStat('💖', 'Love Points', '${widget.tree.lovePoints}'),
              ],
            ),
          ] else ...[
            const Text(
              'Waiting for both partners to plant the tree...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
