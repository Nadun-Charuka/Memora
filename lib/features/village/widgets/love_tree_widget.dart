import 'package:flutter/material.dart';
import 'package:memora/core/models/love_tree.dart'; // Adjust path

class LoveTreeWidget extends StatelessWidget {
  final TreeStage stage;

  const LoveTreeWidget({super.key, required this.stage});

  // This helper function returns the correct image path
  String _getTreeAssetForStage(TreeStage stage) {
    switch (stage) {
      case TreeStage.seedling:
        return 'assets/images/tree_seedling.png'; // 🌱 [cite: 72]
      case TreeStage.growing:
        return 'assets/images/tree_growing.png'; // 🌿 [cite: 72]
      case TreeStage.blooming:
        return 'assets/images/tree_blooming.png'; // 🌸 [cite: 72]
      case TreeStage.mature:
        return 'assets/images/tree_mature.png'; // 🌳 [cite: 72]
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getTreeAssetForStage(stage);

    // You would use Lottie for animations, but PNGs are great for starting
    return Image.asset(
      imagePath,
      height: 300, // Adjust size as needed
    );
  }
}
