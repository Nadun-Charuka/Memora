import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/auth/provider/auth_provider.dart';
import 'package:memora/fetures/love_tree/screens/add_memory_screen.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';
import 'package:memora/fetures/love_tree/widgets/tree_widget.dart';
import 'package:memora/fetures/village/service/village_service.dart';
import 'package:memora/models/tree_model.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic>? _coupleData;
  bool _isLoadingCouple = true;
  String? _coupleId;

  @override
  void initState() {
    super.initState();
    _loadCoupleData();
  }

  Future<void> _loadCoupleData() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final coupleData = await VillageService().getCoupleByUserId(user.uid);

    if (mounted) {
      setState(() {
        _coupleData = coupleData;
        _coupleId = coupleData?['coupleId'];
        _isLoadingCouple = false;
      });
    }
  }

  Future<void> _handlePlantTree() async {
    if (_coupleId == null) return;

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final result = await TreeService().plantTree(_coupleId!, user.uid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Done'),
          backgroundColor: result['success']
              ? Colors.green.shade400
              : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    if (_isLoadingCouple) {
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

    if (_coupleId == null) {
      return Scaffold(
        body: const Center(
          child: Text('No couple found. Please restart the app.'),
        ),
      );
    }

    final villageName = _coupleData?['villageName'] ?? 'Love Village';
    final partner1Name = _coupleData?['partner1Name'] ?? '';
    final partner2Name = _coupleData?['partner2Name'] ?? 'Waiting...';
    final status = _coupleData?['status'] ?? 'pending';

    return Scaffold(
      body: StreamBuilder<LoveTree?>(
        stream: TreeService().getCurrentTreeStream(_coupleId!),
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
            return _buildErrorState();
          }

          return StreamBuilder<List<Memory>>(
            stream: TreeService().getMemoriesStream(_coupleId!),
            builder: (context, memoriesSnapshot) {
              final memories = memoriesSnapshot.data ?? [];

              return Stack(
                children: [
                  // Main tree view
                  Column(
                    children: [
                      // Header
                      Container(
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
                              const Color(0xFF9B85C0).withOpacity(0.9),
                              const Color(0xFFE8B4D9).withOpacity(0.9),
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
                                    villageName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$partner1Name 💞 $partner2Name',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
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
                              onPressed: _showOptionsMenu,
                            ),
                          ],
                        ),
                      ),

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
                        ? _buildAddMemoryFAB()
                        : _buildPlantTreeButton(status),
                  ),

                  // Pending status indicator
                  if (status == 'pending' && !tree.isPlanted)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 80,
                      left: 20,
                      right: 20,
                      child: _buildPendingBanner(),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingBanner() {
    final inviteCode = _coupleData?['inviteCode'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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

  Widget _buildPlantTreeButton(String status) {
    if (status == 'pending') {
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

    return FloatingActionButton.extended(
      onPressed: _handlePlantTree,
      backgroundColor: const Color(0xFF6B9B78),
      icon: const Icon(Icons.park),
      label: const Text(
        'Plant Tree',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddMemoryFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddMemoryScreen(coupleId: _coupleId!),
          ),
        );
      },
      backgroundColor: const Color(0xFF6B9B78),
      child: Icon(Icons.add),
    );
  }

  Widget _buildErrorState() {
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
            const Text(
              'Could not load tree',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoadingCouple = true;
                });
                _loadCoupleData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Village'),
              onTap: () {
                Navigator.pop(context);
                _showVillageInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View All Memories'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to memories list
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
      ),
    );
  }

  void _showVillageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_coupleData?['villageName'] ?? 'Village'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Created', _formatDate(_coupleData?['createdAt'])),
            _buildInfoRow('Status', _coupleData?['status'] ?? 'Unknown'),
            _buildInfoRow(
              'Love Points',
              '${_coupleData?['totalLovePoints'] ?? 0}',
            ),
            _buildInfoRow(
              'Current Streak',
              '${_coupleData?['currentStreak'] ?? 0} days',
            ),
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    // Simple formatting - you can improve this
    return timestamp.toString().split(' ')[0];
  }
}
