import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/memo/service/memory_service.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  final Memory memory;
  final String villageId;
  final String treeId;
  final bool isMyMemory;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    required this.villageId,
    required this.treeId,
    required this.isMyMemory,
  });

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  final MemoryService _memoryService = MemoryService();
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memory?'),
        content: const Text(
          'This memory will be removed from your tree. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final result = await _memoryService.deleteMemory(
      villageId: widget.villageId,
      treeId: widget.treeId,
      memoryId: widget.memory.id,
      userId: user.uid,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memory deleted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Go back to list
    } else {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getEmotionColorForScaffold(widget.memory.emotion),
      appBar: AppBar(
        backgroundColor: _getEmotionColor(widget.memory.emotion),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_getEmotionDisplayName(widget.memory.emotion)),
        actions: [
          if (widget.isMyMemory)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    //TODO:need to handle eddit memo
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.delete),
                  onPressed: _isDeleting ? null : _handleDelete,
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with emotion icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getEmotionColor(widget.memory.emotion),
              ),
              child: Column(
                children: [
                  // Large emotion icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        widget.memory.emotion.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Author
                  Text(
                    widget.memory.addedByName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Date and time
                  Text(
                    _formatFullDateTime(widget.memory.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Memory content
                  Container(
                    width: double.infinity,
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
                    child: Text(
                      widget.memory.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Photo if available
                  if (widget.memory.photoUrl != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.memory.photoUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Info cards
                  _buildInfoCard(
                    icon: Icons.emoji_emotions,
                    label: 'Feeling',
                    value: _getEmotionDisplayName(widget.memory.emotion),
                    color: _getEmotionColor(widget.memory.emotion),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.person,
                    label: 'Added by',
                    value: widget.isMyMemory
                        ? 'You'
                        : widget.memory.addedByName,
                    color: widget.isMyMemory
                        ? const Color(0xFF6B9B78)
                        : const Color(0xFF9B85C0),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: DateFormat('h:mm a').format(widget.memory.createdAt),
                    color: Colors.grey.shade600,
                  ),

                  if (widget.isMyMemory) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting ? null : _handleDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete),
                        label: const Text('Delete Memory'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(dateTime);
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

  Color _getEmotionColorForScaffold(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return const Color.fromARGB(255, 242, 190, 217);
      case MemoryEmotion.happy:
        return const Color.fromARGB(255, 251, 248, 248);
      case MemoryEmotion.joyful:
        return const Color.fromARGB(255, 250, 160, 144);
      case MemoryEmotion.excited:
        return const Color.fromARGB(255, 251, 219, 139);
      case MemoryEmotion.grateful:
        return const Color.fromARGB(255, 254, 238, 148);
      case MemoryEmotion.peaceful:
        return const Color.fromARGB(255, 220, 229, 220);
      case MemoryEmotion.nostalgic:
        return const Color.fromARGB(255, 240, 180, 255);
      case MemoryEmotion.sad:
        return const Color.fromARGB(255, 196, 227, 252);
      case MemoryEmotion.awful:
        return const Color.fromARGB(255, 87, 87, 87);
    }
  }
}
