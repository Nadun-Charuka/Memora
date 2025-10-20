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

class _TreeWidgetState extends State<TreeWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  bool _isCardExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slower for smoother animations
    )..repeat();

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    setState(() {
      _isCardExpanded = !_isCardExpanded;
      if (_isCardExpanded) {
        _cardAnimationController.forward();
      } else {
        _cardAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen tree canvas (no GestureDetector wrapping to avoid blocking interactions)
          Positioned.fill(
            child: CustomPaint(
              size: Size.infinite,
              painter: TreePainter(
                tree: widget.tree,
                memories: widget.memories,
                animation: _animationController,
              ),
            ),
          ),

          // Compact tree info at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _cardAnimationController,
              builder: (context, child) {
                return _buildTreeInfo();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeInfo() {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.90),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact header - always visible
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getStageIcon(widget.tree.stage),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tree.stage.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                        if (widget.tree.isPlanted)
                          Text(
                            '${widget.tree.memoryCount} memories • Lv${widget.tree.level}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    // Quick stats when collapsed
                    AnimatedRotation(
                      turns: _isCardExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: const Color(0xFF6B9B78),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!_isCardExpanded && widget.tree.isPlanted) ...[
                      _buildMiniStat('💚', (widget.tree.health * 100).toInt()),
                      const SizedBox(width: 8),
                      _buildMiniStat(
                        '😊',
                        (widget.tree.happiness * 100).toInt(),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Expanded content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isCardExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildExpandedContent(),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String emoji, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9B78).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$value%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7C59),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (!widget.tree.isPlanted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6B9B78).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6B9B78).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B78).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                color: Color(0xFF4A7C59),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Waiting for both partners to plant the tree...',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A7C59),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Progress section
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A7C59),
                        ),
                      ),
                      Text(
                        '${(widget.tree.stageProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: widget.tree.stageProgress,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6B9B78),
                                Color(0xFF4A7C59),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B9B78).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              '💚',
              'Health',
              '${(widget.tree.health * 100).toInt()}%',
              widget.tree.health,
            ),
            _buildStat(
              '😊',
              'Happiness',
              '${(widget.tree.happiness * 100).toInt()}%',
              widget.tree.happiness,
            ),
            _buildStat(
              '💖',
              'Love',
              '${widget.tree.lovePoints}',
              widget.tree.lovePoints / 1000,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String emoji, String label, String value, double progress) {
    return Column(
      children: [
        // Emoji with background circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatColor(label).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getStatColor(label).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Value
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getStatColor(label),
          ),
        ),
        const SizedBox(height: 2),
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatColor(String label) {
    switch (label) {
      case 'Health':
        return const Color(0xFF4CAF50);
      case 'Happiness':
        return const Color(0xFFFFB74D);
      case 'Love Points':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF6B9B78);
    }
  }

  Widget _getStageIcon(TreeStage stage) {
    String icon;
    switch (stage) {
      case TreeStage.notPlanted:
        icon = '🌱';
        break;
      case TreeStage.seedling:
        icon = '🌱';
        break;
      case TreeStage.growing:
        icon = '🌿';
        break;
      case TreeStage.blooming:
        icon = '🌸';
        break;
      case TreeStage.mature:
        icon = '🌳';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9B78).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        icon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
