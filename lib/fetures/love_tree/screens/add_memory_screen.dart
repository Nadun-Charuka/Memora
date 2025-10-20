import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';
import 'package:memora/models/tree_model.dart';

class AddMemoryScreen extends ConsumerStatefulWidget {
  final String coupleId;

  const AddMemoryScreen({
    super.key,
    required this.coupleId,
  });

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _contentController = TextEditingController();
  MemoryEmotion _selectedEmotion = MemoryEmotion.happy;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleAddMemory() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please write something about this memory', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final result = await TreeService().addMemory(
      coupleId: widget.coupleId,
      userId: user.uid,
      userName: user.displayName ?? 'You',
      content: _contentController.text.trim(),
      emotion: _selectedEmotion,
    );

    if (!mounted) return;

    if (result['success']) {
      _showSnackBar(result['message'], isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(result['message'], isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Memory',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotion selector
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7C59),
              ),
            ),
            const SizedBox(height: 16),
            _buildEmotionSelector(),
            const SizedBox(height: 32),

            // Content input
            const Text(
              'What happened?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7C59),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 8,
              maxLength: 500,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText:
                    'Share this special moment...\n\nExample: "We went to the beach today and watched the sunset together. It was magical! ❤️"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF6B9B78),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B78).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedEmotion.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getEmotionDescription(_selectedEmotion),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A7C59),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _handleAddMemory,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9B78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Add to Tree',
                        style: TextStyle(
                          fontSize: 16,
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

  Widget _buildEmotionSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: MemoryEmotion.values.map((emotion) {
        final isSelected = _selectedEmotion == emotion;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmotion = emotion),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6B9B78)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6B9B78)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emotion.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  emotion.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getEmotionDescription(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.happy:
        return 'This memory will add a beautiful flower to your tree! +6 growth';
      case MemoryEmotion.excited:
        return 'A bird will perch on your tree! +6 growth';
      case MemoryEmotion.joyful:
        return 'Your tree will bear a delicious fruit! +7 growth';
      case MemoryEmotion.grateful:
        return 'A shining star will light up your tree! +5 growth';
      case MemoryEmotion.love:
        return 'A heart will bloom on your tree! +8 growth (Maximum!)';
      case MemoryEmotion.sad:
        return 'Even rain helps trees grow. Your tree will understand. +1 growth';
      case MemoryEmotion.nostalgic:
        return 'A butterfly will visit your tree! +3 growth';
      case MemoryEmotion.peaceful:
        return 'A gentle leaf will appear! +4 growth';
    }
  }
}
