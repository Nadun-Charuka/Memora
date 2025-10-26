import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memora/core/utils/transition.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/memo/screens/memo_details_screen.dart';
import 'package:memora/fetures/memo/service/memory_service.dart';

class MemoryListScreen extends ConsumerStatefulWidget {
  final String villageId;
  final LoveTree tree;

  const MemoryListScreen({
    super.key,
    required this.villageId,
    required this.tree,
  });

  @override
  ConsumerState<MemoryListScreen> createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends ConsumerState<MemoryListScreen> {
  final _memoryService = MemoryService();
  String _filterOption = 'all'; // all, mine, partner

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserAsyncProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<List<Memory>>(
        stream: _memoryService.getMemoriesStream(
          widget.villageId,
          widget.tree.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              appBar: _buildAppBar(widget.tree.memoryCount),
              body: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6B9B78),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              appBar: _buildAppBar(widget.tree.memoryCount),
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
                      'Error loading memories',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
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

          List<Memory> allMemories = snapshot.data ?? [];
          allMemories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Calculate reactive values
          final memoryCount = allMemories.length;
          final progress = memoryCount / widget.tree.maxMemories;
          final remainingMemories = widget.tree.maxMemories - memoryCount;
          final isCompleted = memoryCount >= widget.tree.maxMemories;

          // Apply filter
          List<Memory> memories = allMemories;
          if (_filterOption == 'mine' && currentUser != null) {
            memories = allMemories
                .where((m) => m.addedBy == currentUser.uid)
                .toList();
          } else if (_filterOption == 'partner' && currentUser != null) {
            memories = allMemories
                .where((m) => m.addedBy != currentUser.uid)
                .toList();
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: _buildAppBar(memoryCount),
            body: memories.isEmpty
                ? _buildEmptyState()
                : _buildMemoryList(
                    memories,
                    memoryCount,
                    progress,
                    remainingMemories,
                    isCompleted,
                    currentUser,
                  ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int memoryCount) {
    return AppBar(
      backgroundColor: const Color(0xFF6B9B78),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Memories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${widget.tree.name} • $memoryCount/${widget.tree.maxMemories}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        // Tree stage indicator
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.tree.stage.displayName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          onSelected: (value) {
            setState(() => _filterOption = value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'all',
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 20,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 12),
                  Text('All Memories'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'mine',
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.black,
                  ),
                  SizedBox(width: 12),
                  Text('My Memories'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'partner',
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 20,
                    color: Colors.pink,
                  ),
                  SizedBox(width: 12),
                  Text('Partner\'s Memories'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_satisfied_alt,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _filterOption == 'mine'
                ? 'You haven\'t added any memories yet'
                : _filterOption == 'partner'
                ? 'Your partner hasn\'t added any memories yet'
                : widget.tree.isPlanted
                ? 'No memories yet'
                : 'Tree not planted yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.tree.isPlanted
                ? 'Start creating beautiful moments together!'
                : 'Both partners need to plant the tree first',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryList(
    List<Memory> memories,
    int memoryCount,
    double progress,
    int remainingMemories,
    bool isCompleted,
    dynamic currentUser,
  ) {
    // Group memories by date
    final groupedMemories = _groupMemoriesByDate(memories);

    return Column(
      children: [
        // Tree progress indicator
        if (!isCompleted)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tree Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '$memoryCount/${widget.tree.maxMemories}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B9B78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF6B9B78),
                    minHeight: 8,
                  ),
                ),
                if (remainingMemories <= 10)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '$remainingMemories more to complete! 🎉',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Tree completed banner
        if (isCompleted)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade100,
                  Colors.amber.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tree Completed!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A7C59),
                        ),
                      ),
                      Text(
                        widget.tree.completedAt != null
                            ? 'Completed on ${DateFormat('MMM d, yyyy').format(widget.tree.completedAt!)}'
                            : 'All 60 memories collected!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Memory list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            itemCount: groupedMemories.length,
            itemBuilder: (context, index) {
              final dateKey = groupedMemories.keys.elementAt(index);
              final dateMemories = groupedMemories[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B9B78),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateHeader(dateKey),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Memories for this date
                  ...dateMemories.map((memory) {
                    final isMyMemory = currentUser?.uid == memory.addedBy;
                    return _buildMemoryCard(memory, isMyMemory);
                  }),

                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(Memory memory, bool isMyMemory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          appFadeScaleRoute(
            MemoryDetailScreen(
              memory: memory,
              villageId: widget.villageId,
              treeId: widget.tree.id,
              isMyMemory: isMyMemory,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMyMemory
                ? const Color(0xFF6B9B78).withValues(alpha: 0.2)
                : const Color(0xFF9B85C0).withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Emoji + Author + Time
              Row(
                children: [
                  // Emotion icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getEmotionColor(
                        memory.emotion,
                      ).withValues(alpha: 0.2),
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

                  // Author and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // In the header section, after the author name
                        Row(
                          children: [
                            Text(
                              memory.addedByName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isMyMemory
                                    ? const Color(0xFF6B9B78)
                                    : const Color(0xFF9B85C0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isMyMemory)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6B9B78,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B9B78),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            // Add this for edited indicator
                            if (memory.updatedAt != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Edited',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(memory.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Emotion label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEmotionColor(
                        memory.emotion,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      memory.emotion.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getEmotionColor(memory.emotion),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              if (memory.isHide && !isMyMemory)
                Container(
                  padding: const EdgeInsets.all(16),
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
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              // Photo if available
              if (memory.photoUrl != null) ...[
                const SizedBox(height: 12),
                if (memory.isHide && !isMyMemory)
                  // Blurred placeholder for hidden photo
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.photo_library,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                else
                  // Normal photo display
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      memory.photoUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6B9B78),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<Memory>> _groupMemoriesByDate(List<Memory> memories) {
    final grouped = <String, List<Memory>>{};

    for (var memory in memories) {
      final dateKey = DateFormat('yyyy-MM-dd').format(memory.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(memory);
    }

    // Sort by date descending (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
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
