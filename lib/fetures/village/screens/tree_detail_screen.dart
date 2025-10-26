import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memora/core/utils/transition.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/widgets/tree_widget.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/memo/screens/view_all_memo_screen.dart';
import 'package:memora/fetures/memo/service/memory_service.dart';

class TreeDetailScreen extends ConsumerStatefulWidget {
  final String villageId;
  final LoveTree tree;

  const TreeDetailScreen({
    super.key,
    required this.villageId,
    required this.tree,
  });

  @override
  ConsumerState<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends ConsumerState<TreeDetailScreen> {
  final MemoryService _memoryService = MemoryService();
  bool _isDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<List<Memory>>(
        stream: _memoryService.getMemoriesStream(
          widget.villageId,
          widget.tree.id,
        ),
        builder: (context, snapshot) {
          final memories = snapshot.data ?? [];

          // ✅ FIX: Sort memories by createdAt descending (latest first)
          memories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return CustomScrollView(
            slivers: [
              // App Bar
              _buildSliverAppBar(),

              // Tree Visualization Section
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  color: Colors.white,
                  child: TreeWidget(
                    tree: widget.tree,
                    memories: memories,
                    groundHeight: 0.95,
                    needTreeInfo: false,
                  ),
                ),
              ),

              // Stats Card
              SliverToBoxAdapter(
                child: _buildStatsCard(memories),
              ),

              // ✨ NEW: Emotion Breakdown Card
              SliverToBoxAdapter(
                child: _buildEmotionBreakdownCard(memories),
              ),

              // Tree Info Card (Expandable)
              SliverToBoxAdapter(
                child: _buildExpandableTreeInfoCard(),
              ),

              // Memory Preview Section
              SliverToBoxAdapter(
                child: _buildMemoryPreviewSection(memories),
              ),

              // View All Memories Button
              SliverToBoxAdapter(
                child: _buildViewAllMemoriesButton(),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: _getTreeColor(),
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tree.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                // color: Colors.black87,
              ),
            ),
            Text(
              _getMonthYear(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
                // color: Colors.black54,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTreeColor(),
                _getTreeColor().withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTreeEmoji(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.tree.stage.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(List<Memory> memories) {
    final emotionCounts = _countEmotions(memories);
    final mostUsedEmotion = _getMostUsedEmotion(emotionCounts);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: _getTreeColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tree Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.favorite,
                  label: 'Memories',
                  value:
                      '${widget.tree.memoryCount}/${widget.tree.maxMemories}',
                  color: Colors.pink.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  label: 'Love Points',
                  value: widget.tree.lovePoints.toString(),
                  color: Colors.amber.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Level',
                  value: widget.tree.level.toString(),
                  color: Colors.blue.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_emotions,
                  label: 'Mood',
                  value: mostUsedEmotion.icon,
                  color: Colors.purple.shade400,
                ),
              ),
            ],
          ),

          // Progress bar
          if (!widget.tree.isCompleted) ...[
            const SizedBox(height: 20),
            Text(
              'Growth Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.tree.memoryCount / widget.tree.maxMemories,
                backgroundColor: Colors.grey.shade200,
                color: _getTreeColor(),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(widget.tree.stageProgress * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          // Completion badge
          if (widget.tree.isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade100,
                    Colors.amber.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tree Completed!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                        if (widget.tree.completedAt != null)
                          Text(
                            'Finished on ${DateFormat('MMM d, yyyy').format(widget.tree.completedAt!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✨ NEW: Emotion Breakdown Card
  Widget _buildEmotionBreakdownCard(List<Memory> memories) {
    if (memories.isEmpty) return const SizedBox.shrink();

    final emotionCounts = _countEmotions(memories);
    final totalMemories = memories.length;

    // Sort emotions by count (descending)
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Filter out emotions with 0 count
    final usedEmotions = sortedEmotions.where((e) => e.value > 0).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTreeColor().withValues(alpha: 0.1),
            _getTreeColor().withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTreeColor().withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: _getTreeColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Emotion Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalMemories total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getTreeColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'How was your month together? 💭',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Emotion bars
          ...usedEmotions.map((entry) {
            final emotion = entry.key;
            final count = entry.value;
            final percentage = (count / totalMemories * 100).toInt();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEmotionBar(
                emotion: emotion,
                count: count,
                percentage: percentage,
                totalMemories: totalMemories,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmotionBar({
    required MemoryEmotion emotion,
    required int count,
    required int percentage,
    required int totalMemories,
  }) {
    return Column(
      children: [
        Row(
          children: [
            // Emotion icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getEmotionColor(emotion).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  emotion.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Emotion name
            Expanded(
              flex: 2,
              child: Text(
                _getEmotionDisplayName(emotion),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            // Progress bar
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: count / totalMemories,
                  backgroundColor: Colors.grey.shade200,
                  color: _getEmotionColor(emotion),
                  minHeight: 8,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Count and percentage
            SizedBox(
              width: 60,
              child: Text(
                '$count ($percentage%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getEmotionColor(emotion),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✨ NEW: Expandable Tree Info Card
  Widget _buildExpandableTreeInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isDetailsExpanded = !_isDetailsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getTreeColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tree Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isDetailsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isDetailsExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Created On',
                    value: DateFormat('EEEE, MMM d, yyyy').format(
                      widget.tree.createdAt,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.history,
                    label: 'Last Active',
                    value: DateFormat('EEEE, MMM d, yyyy • h:mm a').format(
                      widget.tree.lastInteraction,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.forest,
                    label: 'Tree Type',
                    value: widget.tree.type,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.height,
                    label: 'Tree Height',
                    value: '${widget.tree.height.toStringAsFixed(1)} units',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.favorite,
                    label: 'Happiness Level',
                    value:
                        '${(widget.tree.happiness * 100).toStringAsFixed(0)}%',
                  ),
                  if (widget.tree.isPlanted) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.check_circle,
                      label: 'Status',
                      value: widget.tree.isCompleted
                          ? 'Completed 🎉'
                          : 'Growing 🌱',
                    ),
                  ],
                  if (widget.tree.completedAt != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.emoji_events,
                      label: 'Completed On',
                      value: DateFormat('EEEE, MMM d, yyyy').format(
                        widget.tree.completedAt!,
                      ),
                    ),
                  ],
                  if (!widget.tree.isCompleted) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.timelapse,
                      label: 'Remaining Memories',
                      value:
                          '${widget.tree.remainingMemories} more to complete',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
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
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTreeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _getTreeColor(), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryPreviewSection(List<Memory> memories) {
    if (memories.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No Memories Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.tree.isPlanted
                  ? 'This tree is waiting for beautiful moments'
                  : 'Plant the tree to start adding memories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Show latest 4 memories (already sorted)
    final recentMemories = memories.take(4).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    color: _getTreeColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Memories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getTreeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${memories.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getTreeColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentMemories.map((memory) => _buildMemoryPreviewCard(memory)),
        ],
      ),
    );
  }

  Widget _buildMemoryPreviewCard(Memory memory) {
    final currentUser = ref.watch(currentUserAsyncProvider);
    final isMyMemory = currentUser?.uid == memory.addedBy;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Emotion icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getEmotionColor(memory.emotion).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                memory.emotion.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (memory.isHide && !isMyMemory)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This memory is private',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    memory.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      memory.addedByName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ${DateFormat('MMM d').format(memory.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chevron
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllMemoriesButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            appFadeScaleRoute(
              MemoryListScreen(
                villageId: widget.villageId,
                tree: widget.tree,
              ),
            ),
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: _getTreeColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.photo_library),
        label: const Text(
          'View All Memories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getTreeColor() {
    if (widget.tree.isCompleted) {
      return const Color(0xFF6B9B78);
    }

    switch (widget.tree.stage) {
      case TreeStage.notPlanted:
        return Colors.grey.shade600;
      case TreeStage.seedling:
        return const Color(0xFFA8E6CF);
      case TreeStage.growing:
        return const Color(0xFF7EC8A3);
      case TreeStage.blooming:
        return const Color(0xFFFF6B9D);
      case TreeStage.mature:
        return const Color(0xFF6B9B78);
      case TreeStage.completed:
        return const Color(0xFFFFD700);
    }
  }

  String _getTreeEmoji() {
    if (widget.tree.isCompleted) return '🏆';
    if (!widget.tree.isPlanted) return '🔒';

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

    final monthIndex = int.tryParse(widget.tree.id.split('_').last) ?? 1;
    return emojis[(monthIndex - 1) % emojis.length];
  }

  String _getMonthYear() {
    try {
      final parts = widget.tree.id.split('_');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy').format(date);
      }
    } catch (e) {
      // Fallback
    }
    return widget.tree.name;
  }

  Map<MemoryEmotion, int> _countEmotions(List<Memory> memories) {
    final counts = <MemoryEmotion, int>{};
    for (var emotion in MemoryEmotion.values) {
      counts[emotion] = 0;
    }
    for (var memory in memories) {
      counts[memory.emotion] = (counts[memory.emotion] ?? 0) + 1;
    }
    return counts;
  }

  MemoryEmotion _getMostUsedEmotion(Map<MemoryEmotion, int> counts) {
    if (counts.isEmpty) return MemoryEmotion.happy;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getEmotionDisplayName(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return 'Love';
      case MemoryEmotion.happy:
        return 'Happy';
      case MemoryEmotion.joyful:
        return 'Joyful';
      case MemoryEmotion.excited:
        return 'Excited';
      case MemoryEmotion.grateful:
        return 'Grateful';
      case MemoryEmotion.peaceful:
        return 'Peaceful';
      case MemoryEmotion.nostalgic:
        return 'Nostalgic';
      case MemoryEmotion.sad:
        return 'Sad';
      case MemoryEmotion.awful:
        return 'Awful';
    }
  }

  Color _getEmotionColor(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return const Color(0xFFFF1493);
      case MemoryEmotion.happy:
        return const Color(0xFFFFB6C1);
      case MemoryEmotion.joyful:
        return const Color(0xFFFF6347);
      case MemoryEmotion.excited:
        return const Color(0xFFDAA520);
      case MemoryEmotion.grateful:
        return const Color(0xFFFFD700);
      case MemoryEmotion.peaceful:
        return const Color(0xFFA1A194);
      case MemoryEmotion.nostalgic:
        return const Color(0xFFBA55D3);
      case MemoryEmotion.sad:
        return const Color(0xFF4682B4);
      case MemoryEmotion.awful:
        return const Color(0xFF292A2E);
    }
  }
}
