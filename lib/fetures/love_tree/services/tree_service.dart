import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';

class TreeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✨ NEW: Check and ensure current month tree exists
  /// Call this on app launch or when navigating to home screen
  Future<MonthTransitionResult> ensureCurrentMonthTree(
    String villageId,
    String userId,
  ) async {
    try {
      final monthKey = _getCurrentMonthKey();
      final lastMonthKey = _getLastMonthKey();

      // Check if current month tree exists
      final currentTreeDoc = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey)
          .get();

      // Check if last month tree exists and is completed
      final lastTreeDoc = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(lastMonthKey)
          .get();

      final hasLastMonthTree = lastTreeDoc.exists;
      final lastTreeData = lastTreeDoc.data();
      final wasLastTreeCompleted = lastTreeData?['isPlanted'] == true;

      // ✅ CASE 1: Current month tree exists - just return it
      if (currentTreeDoc.exists) {
        final tree = LoveTree.fromFirestore(
          currentTreeDoc.data()!,
          currentTreeDoc.id,
        );

        return MonthTransitionResult(
          success: true,
          currentTree: tree,
          transitionType: MonthTransitionType.existing,
          showCelebration: false,
        );
      }

      // ✅ CASE 2: New month detected - create tree & check for celebration
      debugPrint('🌱 New month detected! Creating tree for $monthKey');

      await createMonthlyTree(villageId);

      // Get the newly created tree
      final newTreeDoc = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey)
          .get();

      final newTree = LoveTree.fromFirestore(
        newTreeDoc.data()!,
        newTreeDoc.id,
      );

      // Determine if we should show celebration & auto-plant
      final shouldAutoPlant = hasLastMonthTree && wasLastTreeCompleted;

      if (shouldAutoPlant) {
        // Get village to check if both partners are active
        final villageDoc = await _firestore
            .collection('villages')
            .doc(villageId)
            .get();

        final villageData = villageDoc.data()!;
        final partner1Id = villageData['partner1Id'];
        final partner2Id = villageData['partner2Id'];

        // Auto-plant by both partners (they were active last month)
        await _firestore
            .collection('villages')
            .doc(villageId)
            .collection('trees')
            .doc(monthKey)
            .update({
              'plantedBy': [partner1Id, partner2Id],
              'isPlanted': true,
              'stage': TreeStage.seedling.name,
              'lastInteraction': FieldValue.serverTimestamp(),
            });

        // Update the tree object
        final updatedTreeDoc = await _firestore
            .collection('villages')
            .doc(villageId)
            .collection('trees')
            .doc(monthKey)
            .get();

        final autoPlantedTree = LoveTree.fromFirestore(
          updatedTreeDoc.data()!,
          updatedTreeDoc.id,
        );

        return MonthTransitionResult(
          success: true,
          currentTree: autoPlantedTree,
          lastMonthTree: hasLastMonthTree
              ? LoveTree.fromFirestore(lastTreeData!, lastTreeDoc.id)
              : null,
          transitionType: MonthTransitionType.autoPlanted,
          showCelebration: true,
          celebrationMessage: _getCelebrationMessage(lastTreeData),
        );
      }

      // New month but requires manual planting (first month or inactive last month)
      return MonthTransitionResult(
        success: true,
        currentTree: newTree,
        lastMonthTree: hasLastMonthTree
            ? LoveTree.fromFirestore(lastTreeData!, lastTreeDoc.id)
            : null,
        transitionType: MonthTransitionType.needsPlanting,
        showCelebration: hasLastMonthTree,
        celebrationMessage: hasLastMonthTree
            ? 'Last month\'s tree is complete! Plant your new tree together 🌱'
            : null,
      );
    } catch (e) {
      debugPrint('❌ Error ensuring current month tree: $e');
      return MonthTransitionResult(
        success: false,
        transitionType: MonthTransitionType.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Generate celebration message based on last month's tree
  String _getCelebrationMessage(Map<String, dynamic>? lastTreeData) {
    if (lastTreeData == null) return 'Welcome to a new month! 🌱';

    final memoryCount = lastTreeData['memoryCount'] ?? 0;
    final treeName = lastTreeData['name'] ?? 'your tree';

    if (memoryCount >= 55) {
      return '🎉 Amazing! You completed $treeName with $memoryCount memories!\n'
          'Your new tree is ready and already planted! 💚';
    } else if (memoryCount >= 40) {
      return '✨ Great job! $treeName grew strong with $memoryCount memories!\n'
          'Let\'s make this month even better! 🌱';
    } else if (memoryCount >= 20) {
      return '💫 You added $memoryCount memories last month!\n'
          'Your new tree is planted and waiting for you! 🌿';
    } else {
      return '🌱 A new month brings new opportunities!\n'
          'Your tree is planted - let\'s grow together! 💚';
    }
  }

  /// Get current month key in format: YYYY_MM
  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}';
  }

  /// Get last month key
  String _getLastMonthKey() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return '${lastMonth.year}_${lastMonth.month.toString().padLeft(2, '0')}';
  }

  /// Get current active tree (or most recent if completed)
  Stream<LoveTree?> getCurrentTreeStream(String villageId) {
    final monthKey = _getCurrentMonthKey();

    return _firestore
        .collection('villages')
        .doc(villageId)
        .collection('trees')
        .doc(monthKey)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return LoveTree.fromFirestore(doc.data()!, doc.id);
        });
  }

  /// Get all trees (for history view)
  Stream<List<LoveTree>> getAllTreesStream(String villageId) {
    return _firestore
        .collection('villages')
        .doc(villageId)
        .collection('trees')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LoveTree.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get specific tree by month key
  Future<LoveTree?> getTree(String villageId, String monthKey) async {
    try {
      final doc = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey)
          .get();

      if (!doc.exists) return null;
      return LoveTree.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new tree for current month (called automatically)
  Future<TreeResult> createMonthlyTree(String villageId) async {
    try {
      final monthKey = _getCurrentMonthKey();
      final now = DateTime.now();

      final treeRef = _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey);

      final existing = await treeRef.get();
      if (existing.exists) {
        debugPrint('⚠️ Tree already exists for $monthKey');
        return TreeResult(
          success: false,
          message: 'Tree already exists for this month',
        );
      }

      final tree = LoveTree(
        id: monthKey,
        villageId: villageId,
        name: _getMonthTreeName(now.month),
        type: _getMonthTreeType(now.month),
        level: 1,
        height: 10.0,
        happiness: 1.0,
        lovePoints: 0,
        stage: TreeStage.notPlanted,
        memoryCount: 0,
        isPlanted: false,
        plantedBy: [],
        createdAt: now,
        lastInteraction: now,
      );

      await treeRef.set(tree.toFirestore());
      debugPrint('✅ Created new tree: ${tree.name} for $monthKey');

      return TreeResult(
        success: true,
        message: 'New tree created for ${tree.name}',
      );
    } catch (e) {
      debugPrint('❌ Error creating tree: $e');
      return TreeResult(
        success: false,
        message: 'Failed to create tree: ${e.toString()}',
      );
    }
  }

  /// Plant the tree (both partners must agree)
  Future<TreeResult> plantTree(String villageId, String userId) async {
    try {
      final monthKey = _getCurrentMonthKey();
      final treeRef = _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey);

      final treeDoc = await treeRef.get();

      if (!treeDoc.exists) {
        await createMonthlyTree(villageId);
        return plantTree(villageId, userId);
      }

      final data = treeDoc.data()!;
      final plantedBy = List<String>.from(data['plantedBy'] ?? []);

      if (plantedBy.contains(userId)) {
        return TreeResult(
          success: false,
          message: 'You already planted the tree!',
        );
      }

      plantedBy.add(userId);
      final isPlanted = plantedBy.length >= 2;

      await treeRef.update({
        'plantedBy': plantedBy,
        'isPlanted': isPlanted,
        'stage': isPlanted
            ? TreeStage.seedling.name
            : TreeStage.notPlanted.name,
        'lastInteraction': FieldValue.serverTimestamp(),
      });

      return TreeResult(
        success: true,
        message: isPlanted
            ? '🌱 Tree planted! Start adding memories together!'
            : '🌱 Waiting for your partner to plant...',
      );
    } catch (e) {
      return TreeResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Update tree stats after memory is added/deleted
  Future<void> updateTreeStats({
    required String villageId,
    required String treeId,
    required int memoryCountChange,
    required int lovePointsChange,
    required double heightChange,
    required double happinessChange,
  }) async {
    try {
      final treeRef = _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId);

      final treeDoc = await treeRef.get();
      if (!treeDoc.exists) return;

      final data = treeDoc.data()!;
      final maxMemories = data['maxMemories'];
      final newMemoryCount = ((data['memoryCount'] ?? 0) + memoryCountChange)
          .clamp(0, maxMemories);
      final newHeight = ((data['height'] ?? 10.0) + heightChange).clamp(
        10.0,
        200.0,
      );
      final newHappiness = ((data['happiness'] ?? 1.0) + happinessChange).clamp(
        0.0,
        1.0,
      );
      final newStage = LoveTree.calculateStage(
        newMemoryCount,
        data['isPlanted'] ?? false,
        maxMemories,
      );

      final updates = <String, dynamic>{
        'memoryCount': newMemoryCount,
        'stage': newStage.name,
        'height': newHeight,
        'happiness': newHappiness,
        'lovePoints': FieldValue.increment(lovePointsChange),
        'level': (newMemoryCount ~/ 10) + 1,
        'lastInteraction': FieldValue.serverTimestamp(),
      };

      if (newMemoryCount >= maxMemories && data['completedAt'] == null) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await treeRef.update(updates);
    } catch (e) {
      debugPrint('Error updating tree stats: $e');
    }
  }

  String _getMonthTreeName(int month) {
    const names = [
      'January Seeds',
      'February Blooms',
      'March Growth',
      'April Sunshine',
      'May Flowers',
      'June Dreams',
      'July Warmth',
      'August Radiance',
      'September Harvest',
      'October Colors',
      'November Reflection',
      'December Magic',
    ];
    return names[month - 1];
  }

  String _getMonthTreeType(int month) {
    const types = [
      'PineTree',
      'CherryBlossom',
      'MapleTree',
      'SakuraTree',
      'OakTree',
      'WillowTree',
      'BirchTree',
      'PalmTree',
      'AppleTree',
      'AutumnTree',
      'CypressTree',
      'EvergreenTree',
    ];
    return types[month - 1];
  }
}

class TreeResult {
  final bool success;
  final String message;
  final TreeStage? newStage;

  TreeResult({
    required this.success,
    required this.message,
    this.newStage,
  });
}

/// ✨ NEW: Result for month transition logic
class MonthTransitionResult {
  final bool success;
  final LoveTree? currentTree;
  final LoveTree? lastMonthTree;
  final MonthTransitionType transitionType;
  final bool showCelebration;
  final String? celebrationMessage;
  final String? errorMessage;

  MonthTransitionResult({
    required this.success,
    this.currentTree,
    this.lastMonthTree,
    required this.transitionType,
    this.showCelebration = false,
    this.celebrationMessage,
    this.errorMessage,
  });
}

/// ✨ NEW: Types of month transitions
enum MonthTransitionType {
  existing, // Current month tree already exists
  autoPlanted, // New month, auto-planted (both were active last month)
  needsPlanting, // New month, requires manual planting
  error, // Something went wrong
}
