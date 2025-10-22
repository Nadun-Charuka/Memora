import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/memo/service/memory_service.dart';

class AddMemoryScreen extends ConsumerStatefulWidget {
  final String villageId;

  const AddMemoryScreen({
    super.key,
    required this.villageId,
  });

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _contentController = TextEditingController();
  final _memoryService = MemoryService();
  MemoryEmotion _selectedEmotion = MemoryEmotion.happy;
  bool _isLoading = false;
  bool _checkingEligibility = true;
  bool _canAddToday = false;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkEligibility() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final canAdd = await _memoryService.canAddMemoryToday(
      widget.villageId,
      user.uid,
    );

    if (mounted) {
      setState(() {
        _canAddToday = canAdd;
        _checkingEligibility = false;
      });

      if (!canAdd) {
        _showSnackBar(
          'You\'ve already added a memory today! 💚\nCome back tomorrow to share more moments.',
          isError: true,
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    }
  }

  Future<void> _handleAddMemory() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please write something about this memory', isError: true);
      return;
    }

    if (_contentController.text.trim().length < 10) {
      _showSnackBar(
        'Please write at least 10 characters',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      _showSnackBar('Please login to add memories', isError: true);
      return;
    }

    final result = await _memoryService.addMemory(
      villageId: widget.villageId,
      userId: user.uid,
      userName: user.displayName ?? 'You',
      content: _contentController.text.trim(),
      emotion: _selectedEmotion,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      _showSnackBar(result.message, isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingEligibility) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF6B9B78),
              ),
              const SizedBox(height: 16),
              Text(
                'Checking eligibility...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_canAddToday) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B9B78),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
            // Daily reminder banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B78).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6B9B78).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF4A7C59),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can add one memory per day',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
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

            // Emotion info box
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
                  disabledBackgroundColor: Colors.grey.shade300,
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
          onTap: _isLoading
              ? null
              : () => setState(() => _selectedEmotion = emotion),
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
                  emotion.name.toUpperCase(),
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
      case MemoryEmotion.love:
        return 'A heart will bloom on your tree! +8 growth, +10 love points (Maximum!)';
      case MemoryEmotion.joyful:
        return 'Your tree will bear a delicious fruit! +7 growth, +8 love points';
      case MemoryEmotion.happy:
        return 'This memory will add a beautiful flower to your tree! +6 growth, +6 love points';
      case MemoryEmotion.excited:
        return 'A bird will perch on your tree! +6 growth, +6 love points';
      case MemoryEmotion.grateful:
        return 'A shining star will light up your tree! +5 growth, +5 love points';
      case MemoryEmotion.peaceful:
        return 'A gentle leaf will appear! +4 growth, +4 love points';
      case MemoryEmotion.nostalgic:
        return 'A butterfly will visit your tree! +3 growth, +3 love points';
      case MemoryEmotion.sad:
        return 'Even rain helps trees grow. Your tree will understand. +1 growth, +2 love points';
    }
  }
}
