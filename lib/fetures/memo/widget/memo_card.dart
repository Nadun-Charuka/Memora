import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/memo/model/memo.dart';
import '../providers/memo_provider.dart';

class MemoCard extends ConsumerStatefulWidget {
  final Memo memo;
  final bool isFirst;

  const MemoCard({
    required this.memo,
    this.isFirst = false,
    super.key,
  });

  @override
  ConsumerState<MemoCard> createState() => _MemoCardState();
}

class _MemoCardState extends ConsumerState<MemoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          top: widget.isFirst ? 8 : 0,
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: User info and emotion
                Row(
                  children: [
                    _buildEmotionIcon(widget.memo.emotion),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          currentUserAsync.when(
                            data: (user) => Text(
                              widget.memo.addedBy == user?.id
                                  ? 'You'
                                  : 'Your Partner',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            loading: () => const Text('...'),
                            error: (_, __) => const Text('User'),
                          ),
                          Text(
                            _formatDate(widget.memo.createdAt),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEmotionBadge(widget.memo.emotion),
                  ],
                ),
                const SizedBox(height: 12),

                // Content
                Text(
                  widget.memo.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                // Media (if exists)
                if (widget.memo.mediaUrl != null) ...[
                  const SizedBox(height: 12),
                  _buildMediaPreview(widget.memo.mediaUrl!),
                ],

                const SizedBox(height: 12),

                // Reactions and actions
                Row(
                  children: [
                    // Love points indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.pink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${widget.memo.getPoints()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Reaction button
                    _buildReactionButton(currentUserAsync),
                  ],
                ),

                // Show existing reactions
                if (widget.memo.reactions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildReactionsList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionIcon(EmotionType emotion) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getEmotionColor(emotion).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        _getEmotionEmoji(emotion),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildEmotionBadge(EmotionType emotion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getEmotionColor(emotion).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getEmotionColor(emotion).withOpacity(0.3),
        ),
      ),
      child: Text(
        emotion.name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getEmotionColor(emotion),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(String mediaUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        mediaUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, size: 48),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReactionButton(AsyncValue currentUserAsync) {
    return currentUserAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();

        // Check if user already reacted
        final hasReacted = widget.memo.reactions.any(
          (r) => r.userId == user.id,
        );

        return IconButton(
          onPressed: hasReacted ? null : () => _showReactionPicker(user.id),
          icon: Icon(
            hasReacted ? Icons.favorite : Icons.favorite_border,
            color: hasReacted ? Colors.pink : Colors.grey,
          ),
          tooltip: hasReacted ? 'You reacted' : 'Add reaction',
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  void _showReactionPicker(String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'React to this memory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children: ['❤️', '😍', '🥰', '😊', '👏', '🎉', '💯', '🔥']
                  .map(
                    (emoji) => GestureDetector(
                      onTap: () {
                        ref
                            .read(memoControllerProvider.notifier)
                            .addReaction(widget.memo.id, userId, emoji);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsList() {
    return Wrap(
      spacing: 8,
      children: widget.memo.reactions.map((reaction) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            reaction.emoji,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  String _getEmotionEmoji(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
        return '😊';
      case EmotionType.sad:
        return '😢';
      case EmotionType.nostalgic:
        return '🥰';
      case EmotionType.grateful:
        return '🙏';
      case EmotionType.excited:
        return '🎉';
      case EmotionType.loving:
        return '❤️';
    }
  }

  Color _getEmotionColor(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
      case EmotionType.excited:
        return Colors.orange;
      case EmotionType.sad:
        return Colors.blue;
      case EmotionType.nostalgic:
      case EmotionType.loving:
        return Colors.pink;
      case EmotionType.grateful:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
