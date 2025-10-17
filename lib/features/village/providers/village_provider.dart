import 'package:flutter_riverpod/legacy.dart';
import 'package:memora/core/models/love_tree.dart'; // Adjust import path

// This class will manage the state of our LoveTree
class VillageNotifier extends StateNotifier<LoveTree> {
  VillageNotifier()
    : super(
        // Initial state of the tree when the app starts
        LoveTree(
          id: '2025_10',
          name: 'October Love Tree',
          stage: TreeStage.seedling, // Starts as a seedling [cite: 72]
          lovePoints: 0,
        ),
      );

  // This is where the magic happens!
  // It updates the tree based on the memory added.
  void addHappyMemory() {
    final currentPoints = state.lovePoints;
    final newPoints =
        currentPoints + 5; // +5 love points for a happy memo [cite: 74]

    // Determine the new stage based on love points
    TreeStage newStage = state.stage;
    if (newPoints > 50) {
      newStage = TreeStage.mature;
    } else if (newPoints > 20) {
      newStage = TreeStage.blooming;
    } else if (newPoints > 5) {
      newStage = TreeStage.growing;
    }

    // Update the state. Riverpod will notify all listeners.
    state = state.copyWith(lovePoints: newPoints, stage: newStage);
  }

  // You can add more methods here like addSadMemory(), etc.
}

// Finally, we create the provider that our UI will use to access the VillageNotifier
final villageProvider = StateNotifierProvider<VillageNotifier, LoveTree>((ref) {
  return VillageNotifier();
});
