import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memora/models/tree_model.dart';

class TreeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current month's tree
  Stream<LoveTree?> getCurrentTreeStream(String coupleId) {
    final now = DateTime.now();
    final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('trees')
        .doc(monthKey)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return LoveTree.fromFirestore(doc.data()!, doc.id);
        });
  }

  // Get memories for current tree
  Stream<List<Memory>> getMemoriesStream(String coupleId) {
    final now = DateTime.now();
    final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';

    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('trees')
        .doc(monthKey)
        .collection('memories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Memory.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Plant the tree (both partners must agree)
  Future<Map<String, dynamic>> plantTree(String coupleId, String userId) async {
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';
      final treeRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('trees')
          .doc(monthKey);

      final treeDoc = await treeRef.get();

      if (!treeDoc.exists) {
        return {'success': false, 'message': 'Tree not found'};
      }

      final data = treeDoc.data()!;
      final plantedBy = List<String>.from(data['plantedBy'] ?? []);

      // Check if user already planted
      if (plantedBy.contains(userId)) {
        return {'success': false, 'message': 'You already planted the tree!'};
      }

      // Add user to plantedBy list
      plantedBy.add(userId);

      // If both partners planted, activate the tree
      final isPlanted = plantedBy.length >= 2;

      await treeRef.update({
        'plantedBy': plantedBy,
        'isPlanted': isPlanted,
        'stage': isPlanted
            ? TreeStage.seedling.name
            : TreeStage.notPlanted.name,
        'lastInteraction': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'isPlanted': isPlanted,
        'message': isPlanted
            ? '🌱 Tree planted! Start adding memories together!'
            : '🌱 Waiting for your partner to plant...',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Add a memory to the tree
  Future<Map<String, dynamic>> addMemory({
    required String coupleId,
    required String userId,
    required String userName,
    required String content,
    required MemoryEmotion emotion,
    String? photoUrl,
  }) async {
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';
      final treeRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('trees')
          .doc(monthKey);

      // Check if tree exists and is planted
      final treeDoc = await treeRef.get();
      if (!treeDoc.exists) {
        return {'success': false, 'message': 'Tree not found'};
      }

      final treeData = treeDoc.data()!;
      if (!(treeData['isPlanted'] ?? false)) {
        return {'success': false, 'message': 'Tree must be planted first!'};
      }

      // Create memory
      final memory = Memory(
        id: '',
        content: content,
        emotion: emotion,
        photoUrl: photoUrl,
        addedBy: userId,
        addedByName: userName,
        createdAt: DateTime.now(),
      );

      // Add memory to subcollection
      await treeRef.collection('memories').add(memory.toFirestore());

      // Update tree stats
      final currentMemoryCount = treeData['memoryCount'] ?? 0;
      final newMemoryCount = currentMemoryCount + 1;
      final newStage = LoveTree.calculateStage(newMemoryCount, true);

      // Calculate growth
      final currentHeight = (treeData['height'] ?? 10.0).toDouble();
      final growthAmount = _calculateGrowth(emotion);
      final newHeight = (currentHeight + growthAmount).clamp(10.0, 200.0);

      // Calculate happiness boost
      final currentHappiness = (treeData['happiness'] ?? 1.0).toDouble();
      final happinessBoost = _calculateHappinessBoost(emotion);
      final newHappiness = (currentHappiness + happinessBoost).clamp(0.0, 1.0);

      await treeRef.update({
        'memoryCount': newMemoryCount,
        'stage': newStage.name,
        'height': newHeight,
        'happiness': newHappiness,
        'lovePoints': FieldValue.increment(_calculateLovePoints(emotion)),
        'level': (newMemoryCount ~/ 5) + 1,
        'lastInteraction': FieldValue.serverTimestamp(),
      });

      // Update couple stats
      await _firestore.collection('couples').doc(coupleId).update({
        'totalLovePoints': FieldValue.increment(_calculateLovePoints(emotion)),
        'lastInteraction': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message':
            '${emotion.icon} Memory added! Tree grew ${growthAmount.toStringAsFixed(1)} units!',
        'newStage': newStage.displayName,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Calculate growth amount based on emotion
  double _calculateGrowth(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return 8.0;
      case MemoryEmotion.joyful:
        return 7.0;
      case MemoryEmotion.happy:
        return 6.0;
      case MemoryEmotion.excited:
        return 6.0;
      case MemoryEmotion.grateful:
        return 5.0;
      case MemoryEmotion.peaceful:
        return 4.0;
      case MemoryEmotion.nostalgic:
        return 3.0;
      case MemoryEmotion.sad:
        return 1.0;
    }
  }

  // Calculate happiness boost
  double _calculateHappinessBoost(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
      case MemoryEmotion.joyful:
        return 0.05;
      case MemoryEmotion.happy:
      case MemoryEmotion.excited:
        return 0.04;
      case MemoryEmotion.grateful:
      case MemoryEmotion.peaceful:
        return 0.03;
      case MemoryEmotion.nostalgic:
        return 0.02;
      case MemoryEmotion.sad:
        return 0.01;
    }
  }

  // Calculate love points
  int _calculateLovePoints(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return 10;
      case MemoryEmotion.joyful:
        return 8;
      case MemoryEmotion.happy:
      case MemoryEmotion.excited:
        return 6;
      case MemoryEmotion.grateful:
        return 5;
      case MemoryEmotion.peaceful:
        return 4;
      case MemoryEmotion.nostalgic:
        return 3;
      case MemoryEmotion.sad:
        return 2;
    }
  }

  // Delete a memory
  Future<Map<String, dynamic>> deleteMemory({
    required String coupleId,
    required String memoryId,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';

      final memoryRef = _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('trees')
          .doc(monthKey)
          .collection('memories')
          .doc(memoryId);

      final memoryDoc = await memoryRef.get();
      if (!memoryDoc.exists) {
        return {'success': false, 'message': 'Memory not found'};
      }

      // Check if user owns the memory
      if (memoryDoc.data()!['addedBy'] != userId) {
        return {
          'success': false,
          'message': 'You can only delete your own memories',
        };
      }

      await memoryRef.delete();

      return {'success': true, 'message': 'Memory deleted'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
