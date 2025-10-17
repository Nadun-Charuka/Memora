import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memora/features/village/providers/village_provider.dart'; // Adjust path
import 'package:memora/features/village/widgets/love_tree_widget.dart'; // Adjust path

class VillageScreen extends ConsumerWidget {
  const VillageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the current tree state
    final loveTree = ref.watch(villageProvider);

    return Scaffold(
      // Use a Stack to layer the background, trees, and UI elements
      body: Stack(
        children: [
          // 1. Background (e.g., a sky gradient or image)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. The Main Tree Widget (centered)
          Center(
            child: LoveTreeWidget(stage: loveTree.stage),
          ),

          // 3. UI elements on top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Couple's Village Name [cite: 47]
                  Text(
                    'Nadun 💞 Nathasha Village',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display Love Points for feedback
                  Text(
                    '${loveTree.lovePoints} Love Points',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 4. The "Add Memo" button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Call the method in our provider to add a memory
          // For now, we'll just simulate adding a "happy" memory
          ref.read(villageProvider.notifier).addHappyMemory();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
