import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';

class TreeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      // Check if tree already exists
      final existing = await treeRef.get();
      if (existing.exists) {
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

      return TreeResult(
        success: true,
        message: 'New tree created for ${tree.name}',
      );
    } catch (e) {
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
        // Auto-create tree if it doesn't exist
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
      final newMemoryCount = ((data['memoryCount'] ?? 0) + memoryCountChange)
          .clamp(0, LoveTree.MAX_MEMORIES);
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

      // Mark as completed when 60 memories reached
      if (newMemoryCount >= LoveTree.MAX_MEMORIES &&
          data['completedAt'] == null) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await treeRef.update(updates);
    } catch (e) {
      debugPrint('Error updating tree stats: $e');
    }
  }

  // Helper methods
  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}';
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
