import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memora/core/utils/transition.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';
import 'package:memora/fetures/village/screens/tree_detail_screen.dart';

class VillageHistoryScreen extends ConsumerStatefulWidget {
  final String villageId;

  const VillageHistoryScreen({
    super.key,
    required this.villageId,
  });

  @override
  ConsumerState<VillageHistoryScreen> createState() =>
      _VillageHistoryScreenState();
}

class _VillageHistoryScreenState extends ConsumerState<VillageHistoryScreen> {
  final TreeService _treeService = TreeService();
  String _sortOption = 'newest'; // newest, oldest, most_memories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<List<LoveTree>>(
        stream: _treeService.getAllTreesStream(widget.villageId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          List<LoveTree> trees = snapshot.data ?? [];

          // Apply sorting
          trees = _sortTrees(trees);

          return CustomScrollView(
            slivers: [
              // Custom App Bar
              _buildSliverAppBar(trees.length),

              // Stats Banner
              if (trees.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildStatsBanner(trees),
                ),

              // Empty state
              if (trees.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                ),

              // Grid of trees
              if (trees.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tree = trees[index];
                        final isCurrentMonth = _isCurrentMonth(tree.id);
                        return TreeGridCard(
                          tree: tree,
                          isCurrentMonth: isCurrentMonth,
                          onTap: () => _navigateToTreeDetail(tree),
                        );
                      },
                      childCount: trees.length,
                    ),
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B9B78),
        foregroundColor: Colors.white,
        title: const Text(
          'Love Village History',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6B9B78),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B9B78),
        foregroundColor: Colors.white,
        title: const Text(
          'Love Village History',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading trees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(int treeCount) {
    return SliverAppBar(
      // expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF6B9B78),
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Love Village History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '$treeCount ${treeCount == 1 ? 'tree' : 'trees'} planted',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            setState(() => _sortOption = value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'newest',
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 20,
                    color: _sortOption == 'newest'
                        ? const Color(0xFF6B9B78)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Newest First'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'oldest',
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 20,
                    color: _sortOption == 'oldest'
                        ? const Color(0xFF6B9B78)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Oldest First'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'most_memories',
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 20,
                    color: _sortOption == 'most_memories'
                        ? const Color(0xFF6B9B78)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text('Most Memories'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsBanner(List<LoveTree> trees) {
    final totalMemories = trees.fold<int>(
      0,
      (sum, tree) => sum + tree.memoryCount,
    );
    final totalLovePoints = trees.fold<int>(
      0,
      (sum, tree) => sum + tree.lovePoints,
    );
    final completedTrees = trees.where((t) => t.isCompleted).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B9B78).withValues(alpha: 0.1),
            const Color(0xFF6B9B78).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6B9B78).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Color(0xFF6B9B78),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Journey Together',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '🌳',
                  value: completedTrees.toString(),
                  label: 'Completed',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '💚',
                  value: totalMemories.toString(),
                  label: 'Memories',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '⭐',
                  value: totalLovePoints.toString(),
                  label: 'Love Points',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B9B78),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Trees Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start planting trees by creating memories\nwith your partner!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<LoveTree> _sortTrees(List<LoveTree> trees) {
    switch (_sortOption) {
      case 'newest':
        trees.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        trees.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'most_memories':
        trees.sort((a, b) => b.memoryCount.compareTo(a.memoryCount));
        break;
    }
    return trees;
  }

  bool _isCurrentMonth(String treeId) {
    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}_${now.month.toString().padLeft(2, '0')}';
    return treeId == currentMonthKey;
  }

  void _navigateToTreeDetail(LoveTree tree) {
    Navigator.push(
      context,
      appFadeScaleRoute(
        TreeDetailScreen(
          villageId: widget.villageId,
          tree: tree,
        ),
      ),
    );
  }
}

// ============================================================================
// TREE GRID CARD WIDGET
// ============================================================================

class TreeGridCard extends StatelessWidget {
  final LoveTree tree;
  final bool isCurrentMonth;
  final VoidCallback onTap;

  const TreeGridCard({
    super.key,
    required this.tree,
    required this.isCurrentMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentMonth
                ? const Color(0xFF6B9B78)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tree emoji
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getTreeEmoji(),
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Month name
                  Text(
                    _getMonthName(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    tree.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Memory count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tree.memoryCount}/${tree.maxMemories}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Love points
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tree.lovePoints} pts',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stage badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStageBadgeColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStageIcon(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStageLabel(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Current month indicator
            if (isCurrentMonth)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B9B78),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (tree.isCompleted) {
      return [
        const Color(0xFF6B9B78),
        const Color(0xFF5A8A67),
      ];
    }

    switch (tree.stage) {
      case TreeStage.notPlanted:
        return [Colors.grey.shade400, Colors.grey.shade500];
      case TreeStage.seedling:
        return [const Color(0xFFA8E6CF), const Color(0xFF88D4AB)];
      case TreeStage.growing:
        return [const Color(0xFF7EC8A3), const Color(0xFF6CB693)];
      case TreeStage.blooming:
        return [const Color(0xFFFF6B9D), const Color(0xFFC44569)];
      case TreeStage.mature:
        return [const Color(0xFF6B9B78), const Color(0xFF5A8A67)];
      case TreeStage.completed:
        return [const Color(0xFFFFD700), const Color(0xFFFFB700)];
    }
  }

  String _getTreeEmoji() {
    if (tree.isCompleted) return '🏆';
    if (!tree.isPlanted) return '🌱';

    // Based on tree type or month
    const emojis = [
      '🌲',
      '🌸',
      '🍁',
      '🌳',
      '🌴',
      '🌿',
      '🌺',
      '🍃',
      '🌷',
      '🌻',
      '🎄',
      '🌼',
    ];

    // Use month to determine emoji
    final monthIndex = int.tryParse(tree.id.split('_').last) ?? 1;
    return emojis[(monthIndex - 1) % emojis.length];
  }

  String _getMonthName() {
    try {
      final parts = tree.id.split('_');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy').format(date);
      }
    } catch (e) {
      // Fallback
    }
    return tree.name;
  }

  Color _getStageBadgeColor() {
    if (tree.isCompleted) return Colors.green.shade700;
    if (!tree.isPlanted) return Colors.grey.shade600;

    switch (tree.stage) {
      case TreeStage.seedling:
        return Colors.orange.shade700;
      case TreeStage.growing:
        return Colors.blue.shade700;
      case TreeStage.blooming:
        return Colors.pink.shade700;
      case TreeStage.mature:
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getStageIcon() {
    if (tree.isCompleted) return '✅';
    if (!tree.isPlanted) return '🔒';
    return '🌱';
  }

  String _getStageLabel() {
    if (tree.isCompleted) return 'DONE';
    if (!tree.isPlanted) return 'LOCKED';
    return tree.stage.displayName.toUpperCase();
  }
}
