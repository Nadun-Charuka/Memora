import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:memora/fetures/memo/model/memo.dart';
import 'package:memora/fetures/memo/services/memo_service.dart';
import 'package:memora/fetures/tree/providers/tree_provider.dart';
import 'package:memora/fetures/tree/services/tree_service.dart';

// Memo Service Provider
final memoServiceProvider = Provider((ref) => MemoService());

// Memos Stream Provider
final memosProvider = StreamProvider.family<List<Memo>, String>((ref, treeId) {
  final service = ref.watch(memoServiceProvider);
  return service.getMemosForTree(treeId);
});

// Memo Controller
class MemoController extends StateNotifier<AsyncValue<Memo?>> {
  MemoController(this.service, this.treeService)
    : super(const AsyncValue.data(null));

  final MemoService service;
  final TreeService treeService;

  Future<void> addMemo({
    required String treeId,
    required String coupleId,
    required String userId,
    required String content,
    required EmotionType emotion,
    required MemoType type,
    File? mediaFile,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Add memo
      final memo = await service.addMemo(
        treeId: treeId,
        coupleId: coupleId,
        userId: userId,
        content: content,
        emotion: emotion,
        type: type,
        mediaFile: mediaFile,
      );

      // Update tree growth
      await treeService.updateTreeGrowth(treeId, memo.getPoints());

      return memo;
    });
  }

  Future<void> addReaction(String memoId, String userId, String emoji) async {
    await service.addReaction(memoId, userId, emoji);
    // Add small growth bonus for reactions
    // await treeService.updateTreeGrowth(treeId, 2);
  }
}

final memoControllerProvider =
    StateNotifierProvider<MemoController, AsyncValue<Memo?>>((ref) {
      return MemoController(
        ref.watch(memoServiceProvider),
        ref.watch(treeServiceProvider),
      );
    });
