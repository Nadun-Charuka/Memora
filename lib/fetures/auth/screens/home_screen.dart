import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memora/core/utils/transition.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/screens/add_memory_screen.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';
import 'package:memora/fetures/love_tree/widgets/tree_widget.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/memo/screens/view_all_memo_screen.dart';
import 'package:memora/fetures/memo/service/memory_service.dart';
import 'package:memora/fetures/village/model/village_model.dart';
import 'package:memora/fetures/village/screens/village_history_screen.dart';
import 'package:memora/fetures/village/service/village_service.dart';

import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final VillageService _villageService = VillageService();
  final TreeService _treeService = TreeService();
  final MemoryService _memoryService = MemoryService();

  String? _villageId;
  bool _isLoadingVillage = true;
  bool _hasAddedMemoryToday = false;

  @override
  void initState() {
    super.initState();
    _loadVillageId();
  }

  Future<void> _loadVillageId() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final villageId = await _villageService.getUserVillageId(user.uid);

    if (mounted && villageId != null) {
      // Check if user added memory today
      final canAdd = await _memoryService.canAddMemoryToday(
        villageId,
        user.uid,
      );

      setState(() {
        _villageId = villageId;
        _hasAddedMemoryToday = !canAdd;
        _isLoadingVillage = false;
      });
    } else if (mounted) {
      setState(() {
        _villageId = villageId;
        _isLoadingVillage = false;
      });
    }
  }

  Future<void> _handlePlantTree() async {
    if (_villageId == null) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final result = await _treeService.plantTree(_villageId!, user.uid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success
              ? Colors.green.shade400
              : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✨ NEW: Better UX for add memory button
  Future<void> _handleAddMemory() async {
    if (_villageId == null) return;
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final canAdd = await _memoryService.canAddMemoryToday(
      _villageId!,
      user.uid,
    );

    if (!canAdd) {
      _showAlreadyAddedTodayDialog();
      return;
    }

    if (mounted) {
      final result = await Navigator.of(
        context,
      ).push(appFadeScaleRoute(AddMemoryScreen(villageId: _villageId!)));

      if (result == true && mounted) {
        setState(() {
          _hasAddedMemoryToday = true;
        });
      }
    }
  }

  // ✨ NEW: Friendly dialog for already added today
  void _showAlreadyAddedTodayDialog() {
    showSmoothDialog(
      context: context,
      dialog: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('💚'),
            SizedBox(width: 8),
            Text(
              'All Set for Today!',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You\'ve already added your daily memory! 🌱',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B78).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6B9B78).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: const Color(0xFF6B9B78),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Why one per day?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daily memories help your tree grow steadily and encourage both partners to contribute equally. Come back tomorrow to share another moment! 💫',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to view all memories
              _navigateToAllMemories();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6B9B78),
            ),
            child: const Text('View Memories'),
          ),
        ],
      ),
    );
  }

  // ✨ FIXED: Correct navigation to all memories
  Future<void> _navigateToAllMemories() async {
    if (_villageId == null) return;

    // Get the current month's tree (not village.id!)
    final monthKey = _getCurrentMonthKey();
    final tree = await _treeService.getTree(_villageId!, monthKey);

    if (mounted && tree != null) {
      Navigator.of(context).push(
        appFadeScaleRoute(
          MemoryListScreen(
            tree: tree,
            villageId: _villageId!,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load memories'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper to get current month key
  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authControllerProvider).signOut();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingVillage) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9B85C0),
                const Color(0xFFE8B4D9),
                const Color(0xFFFFF4E6),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_villageId == null) {
      return Scaffold(
        body: const Center(
          child: Text('No village found. Please restart the app.'),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<Village?>(
        stream: _villageService.getVillageStream(_villageId!),
        builder: (context, villageSnapshot) {
          if (villageSnapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9B85C0),
                    const Color(0xFFE8B4D9),
                    const Color(0xFFFFF4E6),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final village = villageSnapshot.data;
          if (village == null) {
            return _buildErrorState('Village not found');
          }

          return StreamBuilder<LoveTree?>(
            stream: _treeService.getCurrentTreeStream(_villageId!),
            builder: (context, treeSnapshot) {
              if (treeSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF87CEEB),
                        const Color(0xFFE0F6FF),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              final tree = treeSnapshot.data;
              if (tree == null) {
                return _buildErrorState('Tree not found');
              }

              return StreamBuilder<List<Memory>>(
                stream: _memoryService.getCurrentMemoriesStream(_villageId!),
                builder: (context, memoriesSnapshot) {
                  final memories = memoriesSnapshot.data ?? [];

                  return Stack(
                    children: [
                      // Main tree view
                      Column(
                        children: [
                          // Header
                          _buildHeader(village),

                          // Tree display
                          Expanded(
                            child: TreeWidget(
                              tree: tree,
                              memories: memories,
                            ),
                          ),
                        ],
                      ),

                      // Plant tree button or Add memory button
                      Positioned(
                        bottom: 200,
                        right: 10,
                        child: tree.isPlanted
                            ? (tree.isCompleted
                                  ? _buildCongratulationsBanner()
                                  : _buildAddMemoryFAB())
                            : _buildPlantTreeButton(village),
                      ),

                      // Pending status indicator
                      if (village.isPending && !tree.isPlanted)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 80,
                          left: 20,
                          right: 20,
                          child: _buildPendingBanner(village.inviteCode),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(Village village) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B85C0),
            const Color(0xFFE8B4D9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B85C0).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Left: Village Info Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showVillageInfo(village),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dual Avatar (both partners)
                        SizedBox(
                          width: 36,
                          height: 28,
                          child: Stack(
                            children: [
                              // Partner 1
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      village.partner1Name
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9B85C0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Partner 2
                              if (village.partner2Name != null)
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        village.partner2Name!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFE8B4D9),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Village Name
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            village.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Center: App Branding
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '💞',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // App Name with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.8),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Memora',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right: Menu Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showOptionsMenu(village),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ BONUS: Enhanced Village Info Dialog
  void _showVillageInfo(Village village) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9B85C0).withValues(alpha: 0.1),
                const Color(0xFFE8B4D9).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF9B85C0),
                          Color(0xFFE8B4D9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          village.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Your Love Village',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats
              _buildVillageInfoRow(
                icon: Icons.people,
                label: 'Partners',
                value:
                    '${village.partner1Name} & ${village.partner2Name ?? "..."}',
              ),
              const SizedBox(height: 16),
              _buildVillageInfoRow(
                icon: Icons.calendar_today,
                label: 'Created',
                value: DateFormat('MMM d, yyyy').format(village.createdAt),
              ),
              const SizedBox(height: 16),
              _buildVillageInfoRow(
                icon: Icons.star,
                label: 'Love Points',
                value: '${village.totalLovePoints}',
              ),
              const SizedBox(height: 16),
              _buildVillageInfoRow(
                icon: Icons.local_fire_department,
                label: 'Current Streak',
                value: '${village.currentStreak} days',
              ),
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF9B85C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVillageInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF9B85C0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF9B85C0),
            size: 20,
          ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingBanner(String inviteCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Waiting for partner',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Code: ',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  inviteCode,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantTreeButton(Village village) {
    if (village.isPending) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Wait for partner',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // NEW: Check if current user has already planted
    return StreamBuilder<LoveTree?>(
      stream: _treeService.getCurrentTreeStream(_villageId!),
      builder: (context, snapshot) {
        final tree = snapshot.data;
        final user = ref.read(authServiceProvider).currentUser;
        final hasUserPlanted = tree?.plantedBy.contains(user?.uid) ?? false;
        final buttonText = hasUserPlanted
            ? 'Waiting for partner'
            : 'Plant Tree';
        final buttonIcon = hasUserPlanted ? Icons.hourglass_empty : Icons.park;

        return FloatingActionButton.extended(
          onPressed: hasUserPlanted ? null : _handlePlantTree,
          backgroundColor: hasUserPlanted
              ? Colors.grey.shade400
              : const Color(0xFF6B9B78),
          icon: Icon(buttonIcon),
          label: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  // ✨ IMPROVED: Visual indicator if already added today
  Widget _buildAddMemoryFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show indicator if already added today
        if (_hasAddedMemoryToday)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF6B9B78),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Added today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        FloatingActionButton(
          onPressed: _handleAddMemory,
          backgroundColor: const Color(0xFF6B9B78),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildCongratulationsBanner() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Congratulations!'),
            content: const Text(
              'Your Love Tree is fully grown! This shows how consistent and caring your relationship has been. 💚',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Yay!'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events, color: Color(0xFF6B9B78), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB),
            const Color(0xFFE0F6FF),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoadingVillage = true;
                });
                _loadVillageId();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(Village village) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final user = ref.read(authServiceProvider).currentUser;
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9B85C0),
                              Color(0xFFE8B4D9),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF9B85C0,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.displayName?.substring(0, 1).toUpperCase() ??
                                '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Name
                      Text(
                        user?.displayName ?? 'User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                ),

                // Menu Options
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Village Info
                      _buildMenuTile(
                        context: context,
                        icon: Icons.info_outline,
                        iconColor: const Color(0xFF6B9B78),
                        iconBgColor: const Color(
                          0xFF6B9B78,
                        ).withValues(alpha: 0.1),
                        title: 'About Village',
                        subtitle: village.name,
                        onTap: () {
                          Navigator.pop(context);
                          _showVillageInfo(village);
                        },
                      ),

                      const SizedBox(height: 8),

                      // Village History
                      _buildMenuTile(
                        context: context,
                        icon: Icons.forest,
                        iconColor: const Color(0xFF8B7355),
                        iconBgColor: const Color(
                          0xFF8B7355,
                        ).withValues(alpha: 0.1),
                        title: 'Village History',
                        subtitle: 'View all your trees',
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF8B7355),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            appFadeScaleRoute(
                              VillageHistoryScreen(villageId: _villageId!),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // View All Memories
                      _buildMenuTile(
                        context: context,
                        icon: Icons.photo_library,
                        iconColor: const Color(0xFF9B85C0),
                        iconBgColor: const Color(
                          0xFF9B85C0,
                        ).withValues(alpha: 0.1),
                        title: 'All Memories',
                        subtitle: 'View current month memories',
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToAllMemories();
                        },
                      ),

                      const SizedBox(height: 8),

                      // Profile
                      _buildMenuTile(
                        context: context,
                        icon: Icons.person,
                        iconColor: Colors.blue.shade600,
                        iconBgColor: Colors.blue.withValues(alpha: 0.1),
                        title: 'Profile',
                        subtitle: 'Edit your profile',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to profile
                        },
                      ),
                    ],
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(
                    height: 24,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
                ),

                // Sign Out Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _buildMenuTile(
                    context: context,
                    icon: Icons.logout,
                    iconColor: Colors.red.shade600,
                    iconBgColor: Colors.red.withValues(alpha: 0.1),
                    title: 'Sign Out',
                    subtitle: 'Logout from your account',
                    titleColor: Colors.red.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      _handleSignOut();
                    },
                  ),
                ),

                // Bottom Safe Area
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✨ NEW: Beautiful Menu Tile Widget
  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? Colors.grey.shade800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
