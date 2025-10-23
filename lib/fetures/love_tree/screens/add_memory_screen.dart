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

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen>
    with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _memoryService = MemoryService();
  final _focusNode = FocusNode();

  MemoryEmotion _selectedEmotion = MemoryEmotion.happy;
  bool _isLoading = false;
  bool _checkingEligibility = true;
  bool _canAddToday = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutCubic,
          ),
        );

    _checkEligibility();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    _animController.dispose();
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
        _showErrorDialog();
      } else {
        _animController.forward();
      }
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B78).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💚', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All Set for Today!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve already shared a memory today. Come back tomorrow to continue growing your tree! 🌱',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B9B78),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Got it!'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddMemory() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      _showSnackBar('Please write something about this memory 📝');
      return;
    }

    if (content.length < 10) {
      _showSnackBar('Please write at least 10 characters ✍️');
      return;
    }

    // Unfocus keyboard
    _focusNode.unfocus();

    setState(() => _isLoading = true);

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      _showSnackBar('Please login to add memories');
      return;
    }

    final result = await _memoryService.addMemory(
      villageId: widget.villageId,
      userId: user.uid,
      userName: user.displayName ?? 'You',
      content: content,
      emotion: _selectedEmotion,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      _showSuccessDialog(result.message);
    } else {
      _showSnackBar(result.message);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B78).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _selectedEmotion.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Memory Added!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B9B78),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('View Tree'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B9B78),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
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
                'Preparing...',
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emotion Selector
                        _buildEmotionSection(),
                        const SizedBox(height: 24),

                        // Content Input
                        _buildContentSection(),
                        const SizedBox(height: 20),

                        // Growth Preview Card
                        _buildGrowthPreview(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Memory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Share your moment 🌱',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Inside the Row in _buildHeader(), replace the Container with "Today" badge:
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6B9B78).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6B9B78).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.today,
                  size: 14,
                  color: Color(0xFF6B9B78),
                ),
                const SizedBox(width: 6),
                Text(
                  '1 memo per day',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MemoryEmotion.values.map((emotion) {
              final isSelected = _selectedEmotion == emotion;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildEmotionChip(emotion, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionChip(MemoryEmotion emotion, bool isSelected) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => setState(() => _selectedEmotion = emotion),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B9B78) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF6B9B78).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              emotion.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              emotion.name.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Text(
              'What happened?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
          child: TextField(
            controller: _contentController,
            focusNode: _focusNode,
            maxLines: 8,
            maxLength: 500,
            enabled: !_isLoading,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText:
                  'Share your special moment...\n\nTip: Be specific! "We watched the sunset at the beach" is better than "Had fun today"',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                height: 1.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthPreview() {
    final stats = _getEmotionStats(_selectedEmotion);

    return Container(
      padding: const EdgeInsets.all(16),
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
          color: const Color(0xFF6B9B78).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _selectedEmotion.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Text(
                '${_selectedEmotion.name.toUpperCase()} Impact',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7C59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBadge(
                  '🌱 +${stats['growth']}',
                  'Growth',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBadge(
                  '💚 +${stats['love']}',
                  'Love Points',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stats['description']!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B9B78),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
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
              elevation: 0,
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add to Tree',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getEmotionStats(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return {
          'growth': '8.0',
          'love': '10',
          'description':
              'A beautiful heart will bloom on your tree! This is the most powerful memory.',
        };
      case MemoryEmotion.joyful:
        return {
          'growth': '7.0',
          'love': '8',
          'description':
              'Your tree will bear delicious fruit to celebrate this joyful moment!',
        };
      case MemoryEmotion.happy:
        return {
          'growth': '6.0',
          'love': '6',
          'description':
              'A beautiful flower will bloom, adding color to your growing tree.',
        };
      case MemoryEmotion.excited:
        return {
          'growth': '6.0',
          'love': '6',
          'description':
              'A cheerful bird will perch on your branches, bringing life to your tree!',
        };
      case MemoryEmotion.grateful:
        return {
          'growth': '5.0',
          'love': '5',
          'description':
              'A shining star will light up your tree, showing appreciation.',
        };
      case MemoryEmotion.peaceful:
        return {
          'growth': '4.0',
          'love': '4',
          'description': 'Cute rabbit will jump on your garden.',
        };
      case MemoryEmotion.nostalgic:
        return {
          'growth': '3.0',
          'love': '3',
          'description':
              'A butterfly will visit, reminding you of beautiful past moments.',
        };
      case MemoryEmotion.sad:
        return {
          'growth': '1.0',
          'love': '2',
          'description':
              'Even rain helps trees grow. Your tree supports you through all emotions.',
        };
    }
  }
}
