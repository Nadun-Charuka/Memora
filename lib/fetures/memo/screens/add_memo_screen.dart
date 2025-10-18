import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memora/fetures/memo/model/memo.dart';
import 'package:memora/fetures/memo/providers/memo_provider.dart';
import 'package:memora/fetures/tree/model/love_tree.dart';

class AddMemoSheet extends ConsumerStatefulWidget {
  final LoveTree tree;

  const AddMemoSheet({required this.tree, super.key});

  @override
  ConsumerState<AddMemoSheet> createState() => _AddMemoSheetState();
}

class _AddMemoSheetState extends ConsumerState<AddMemoSheet> {
  final _contentController = TextEditingController();
  EmotionType _selectedEmotion = EmotionType.happy;
  MemoType _selectedType = MemoType.text;
  File? _selectedMedia;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 20),
            const Text(
              'Add a Memory',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Emotion picker
            const Text(
              'How do you feel?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildEmotionPicker(),
            const SizedBox(height: 20),

            // Content input
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Media picker
            if (_selectedMedia != null) _buildMediaPreview(),

            Row(
              children: [
                _buildMediaButton(Icons.photo, 'Photo', MemoType.photo),
                const SizedBox(width: 12),
                _buildMediaButton(Icons.mic, 'Voice', MemoType.voice),
              ],
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Tree',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildEmotionPicker() {
    return Wrap(
      spacing: 12,
      children: EmotionType.values.map((emotion) {
        final isSelected = _selectedEmotion == emotion;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmotion = emotion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.pink : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              '${_getEmotionEmoji(emotion)} ${emotion.name}',
              style: TextStyle(
                color: isSelected ? Colors.pink.shade900 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMediaButton(IconData icon, String label, MemoType type) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _pickMedia(type),
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(_selectedMedia!),
          fit: BoxFit.cover,
        ),
      ),
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

  Future<void> _pickMedia(MemoType type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedMedia = File(image.path);
        _selectedType = type;
      });
    }
  }

  Future<void> _submit() async {
    if (_contentController.text.isEmpty) return;

    await ref
        .read(memoControllerProvider.notifier)
        .addMemo(
          treeId: widget.tree.id,
          coupleId: widget.tree.coupleId,
          userId: 'current_user_id', // Get from auth provider
          content: _contentController.text,
          emotion: _selectedEmotion,
          type: _selectedType,
          mediaFile: _selectedMedia,
        );

    if (mounted) Navigator.pop(context);
  }
}
