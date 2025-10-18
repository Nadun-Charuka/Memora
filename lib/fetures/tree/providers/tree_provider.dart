import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memora/fetures/tree/model/love_tree.dart';
import 'package:memora/fetures/tree/services/tree_service.dart';

// Tree Service Provider
final treeServiceProvider = Provider((ref) => TreeService());

// Current Tree Stream Provider
final currentTreeProvider = StreamProvider.family<LoveTree?, String>((
  ref,
  coupleId,
) {
  final service = ref.watch(treeServiceProvider);
  return service.getCurrentTree(coupleId);
});

// All Trees Stream Provider (for village)
final allTreesProvider = StreamProvider.family<List<LoveTree>, String>((
  ref,
  coupleId,
) {
  final service = ref.watch(treeServiceProvider);
  return service.getAllTrees(coupleId);
});

// Tree Growth Controller
class TreeController extends StateNotifier<AsyncValue<void>> {
  TreeController(this.service) : super(const AsyncValue.data(null));

  final TreeService service;

  Future<void> createMonthlyTree(String coupleId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => service.createMonthlyTree(coupleId));
  }

  Future<void> updateGrowth(String treeId, int points) async {
    await service.updateTreeGrowth(treeId, points);
  }
}

final treeControllerProvider =
    StateNotifierProvider<TreeController, AsyncValue<void>>((ref) {
      return TreeController(ref.watch(treeServiceProvider));
    });
