import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';
import 'package:memora/fetures/memo/screens/memo_details_screen.dart';
import 'package:memora/models/tree_model.dart';

class MemoryListScreen extends ConsumerStatefulWidget {
  final String coupleId;
  final LoveTree tree;

  const MemoryListScreen({
    super.key,
    required this.coupleId,
    required this.tree,
  });

  @override
  ConsumerState<MemoryListScreen> createState() => _MemoryListScreenState();
}

class _MemoryListScreenState extends ConsumerState<MemoryListScreen> {
  String _filterOption = 'all'; // all, mine, partner

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B85C0),
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
              widget.tree.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
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
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 12),
                    Text('All Memories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mine',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('My Memories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'partner',
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 20),
                    SizedBox(width: 12),
                    Text('Partner\'s Memories'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Memory>>(
        stream: TreeService().getMemoriesStream(widget.coupleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B9B78),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
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
                ],
              ),
            );
          }

          List<Memory> memories = snapshot.data ?? [];

          // Apply filter
          if (_filterOption == 'mine' && currentUser != null) {
            memories = memories
                .where((m) => m.addedBy == currentUser.uid)
                .toList();
          } else if (_filterOption == 'partner' && currentUser != null) {
            memories = memories
                .where((m) => m.addedBy != currentUser.uid)
                .toList();
          }

          if (memories.isEmpty) {
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
                        : 'No memories yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start creating beautiful moments together!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group memories by date
          final groupedMemories = _groupMemoriesByDate(memories);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                    child: Text(
                      _formatDateHeader(dateKey),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
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
          );
        },
      ),
    );
  }

  Widget _buildMemoryCard(Memory memory, bool isMyMemory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryDetailScreen(
              memory: memory,
              coupleId: widget.coupleId,
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
                      memory.emotion.displayName,
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
        return const Color(0xFF90EE90);
      case MemoryEmotion.nostalgic:
        return const Color(0xFFBA55D3);
      case MemoryEmotion.sad:
        return const Color(0xFF4682B4);
    }
  }
}
