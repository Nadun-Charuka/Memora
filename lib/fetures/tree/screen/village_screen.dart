import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/memo/screens/add_memo_screen.dart';
import 'package:memora/fetures/tree/model/love_tree.dart';
import 'package:memora/fetures/tree/providers/tree_provider.dart';
import 'package:memora/fetures/tree/widget/tree_widget.dart';

class VillageScreen extends ConsumerWidget {
  final String coupleId;

  const VillageScreen({required this.coupleId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTreeAsync = ref.watch(currentTreeProvider(coupleId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: currentTreeAsync.when(
        data: (tree) {
          if (tree == null) {
            // No tree for this month - create one
            return _buildCreateTreePrompt(context, ref);
          }
          return _buildVillageView(context, ref, tree);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: currentTreeAsync.value != null
          ? FloatingActionButton(
              onPressed: () =>
                  _showAddMemoSheet(context, ref, currentTreeAsync.value!),
              backgroundColor: Colors.pink,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCreateTreePrompt(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          const Text(
            'Start Your Love Journey',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(treeControllerProvider.notifier)
                  .createMonthlyTree(coupleId);
            },
            child: const Text('Plant Your First Tree'),
          ),
        ],
      ),
    );
  }

  Widget _buildVillageView(BuildContext context, WidgetRef ref, LoveTree tree) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8D5FF), Color(0xFFFFF0F5)],
            ),
          ),
        ),

        // Main content
        SafeArea(
          child: Column(
            children: [
              _buildHeader(tree),
              Expanded(
                child: Center(
                  child: TreeWidget(tree: tree),
                ),
              ),
              _buildStatsBar(tree),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(LoveTree tree) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tree.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Level ${tree.level}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.pink, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${tree.lovePoints}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(LoveTree tree) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.favorite,
            label: 'Happiness',
            value: '${(tree.happiness * 100).toInt()}%',
            color: Colors.pink,
          ),
          _buildStatItem(
            icon: Icons.eco,
            label: 'Health',
            value: '${(tree.health * 100).toInt()}%',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.height,
            label: 'Height',
            value: '${tree.height.toInt()}cm',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  void _showAddMemoSheet(BuildContext context, WidgetRef ref, LoveTree tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMemoSheet(tree: tree),
    );
  }
}
