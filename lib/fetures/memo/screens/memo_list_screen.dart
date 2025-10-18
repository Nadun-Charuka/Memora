import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/fetures/memo/model/memo.dart';
import 'package:memora/fetures/memo/providers/memo_provider.dart';
import 'package:memora/fetures/memo/widget/memo_card.dart';

class MemoListScreen extends ConsumerWidget {
  final String treeId;
  final String treeName;

  const MemoListScreen({
    required this.treeId,
    required this.treeName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memosAsync = ref.watch(memosProvider(treeId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Memories', style: TextStyle(fontSize: 18)),
            Text(
              treeName,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8D5FF), Color(0xFFFFF0F5)],
          ),
        ),
        child: memosAsync.when(
          data: (memos) {
            if (memos.isEmpty) {
              return _buildEmptyState();
            }
            return _buildMemoList(memos);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          const Text(
            'No memories yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start adding memories to grow your tree!',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMemoList(List<Memo> memos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memos.length,
      itemBuilder: (context, index) {
        return MemoCard(
          memo: memos[index],
          isFirst: index == 0,
        );
      },
    );
  }
}
