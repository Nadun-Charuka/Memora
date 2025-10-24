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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B85C0).withValues(alpha: 0.9),
            const Color(0xFFE8B4D9).withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  village.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${village.partner1Name} 💞 ${village.partner2Name ?? "Waiting..."}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () => _showOptionsMenu(village),
          ),
        ],
      ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final user = ref.read(authServiceProvider).currentUser;
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_2_outlined),
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        const TextSpan(text: 'Account Name: '),
                        TextSpan(
                          text: user == null
                              ? "Loading..."
                              : (user.displayName ?? "?"),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Village'),
                  onTap: () {
                    Navigator.pop(context);
                    _showVillageInfo(village);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('View All Memories'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAllMemories();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleSignOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showVillageInfo(Village village) {
    showSmoothDialog(
      context: context,
      dialog: AlertDialog(
        title: Text(village.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Created',
              DateFormat('MMM d, yyyy').format(village.createdAt),
            ),
            _buildInfoRow('Status', village.status.name),
            _buildInfoRow('Love Points', '${village.totalLovePoints}'),
            _buildInfoRow('Current Streak', '${village.currentStreak} days'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
