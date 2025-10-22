// ============================================================================
// MEMORY SERVICE - Complete Implementation
// services/memory_service.dart
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memora/fetures/love_tree/model/tree_model.dart';
import 'package:memora/fetures/love_tree/services/tree_service.dart';
import 'package:memora/fetures/memo/model/memory_model.dart';
import 'package:memora/fetures/village/service/village_service.dart';

/// Service responsible for memory CRUD operations
/// Handles adding, deleting, and retrieving memories
class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TreeService _treeService = TreeService();
  final VillageService _villageService = VillageService();

  /// Get memories for a specific tree
  Stream<List<Memory>> getMemoriesStream(String villageId, String treeId) {
    return _firestore
        .collection('villages')
        .doc(villageId)
        .collection('trees')
        .doc(treeId)
        .collection('memories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Memory.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get current month's memories
  Stream<List<Memory>> getCurrentMemoriesStream(String villageId) {
    final monthKey = _getCurrentMonthKey();
    return getMemoriesStream(villageId, monthKey);
  }

  /// Get memories count for a specific tree
  Future<int> getMemoryCount(String villageId, String treeId) async {
    try {
      final snapshot = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId)
          .collection('memories')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Check if user can add memory today (one per user per day rule)
  Future<bool> canAddMemoryToday(String villageId, String userId) async {
    try {
      final monthKey = _getCurrentMonthKey();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      //for testing purpose we can change this so now user can add memo after 1 minute after adding one memo
      final todayEnd = todayStart.add(const Duration(minutes: 1));

      final todayMemories = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey)
          .collection('memories')
          .where('addedBy', isEqualTo: userId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      return todayMemories.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Add a new memory (ONE PER USER PER DAY)
  Future<MemoryResult> addMemory({
    required String villageId,
    required String userId,
    required String userName,
    required String content,
    required MemoryEmotion emotion,
    String? photoUrl,
  }) async {
    try {
      final monthKey = _getCurrentMonthKey();
      final treeRef = _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(monthKey);

      // Check if tree exists and is planted
      final treeDoc = await treeRef.get();
      if (!treeDoc.exists) {
        return MemoryResult(
          success: false,
          message:
              'Tree not found for this month. Please plant the tree first.',
        );
      }

      final treeData = treeDoc.data()!;

      // Check if tree is planted
      if (!(treeData['isPlanted'] ?? false)) {
        return MemoryResult(
          success: false,
          message:
              'Tree must be planted first! 🌱\nBoth partners need to plant the tree.',
        );
      }

      // Check if tree is completed
      final memoryCount = treeData['memoryCount'] ?? 0;
      if (memoryCount >= LoveTree.MAX_MEMORIES) {
        return MemoryResult(
          success: false,
          message:
              '🎉 This tree is complete with 60 memories!\nA new tree will start next month.',
          treeCompleted: true,
        );
      }

      // Check if user already added a memory today
      if (!await canAddMemoryToday(villageId, userId)) {
        return MemoryResult(
          success: false,
          message:
              'You\'ve already added a memory today! 💚\nCome back tomorrow to share more moments.',
        );
      }

      // Create memory object
      final memory = Memory(
        id: '',
        content: content,
        emotion: emotion,
        photoUrl: photoUrl,
        addedBy: userId,
        addedByName: userName,
        createdAt: DateTime.now(),
      );

      // Add memory to Firestore subcollection
      await treeRef.collection('memories').add(memory.toFirestore());

      // Calculate growth effects based on emotion
      final growthAmount = _calculateGrowth(emotion);
      final happinessBoost = _calculateHappinessBoost(emotion);
      final lovePoints = _calculateLovePoints(emotion);

      // Update tree stats
      await _treeService.updateTreeStats(
        villageId: villageId,
        treeId: monthKey,
        memoryCountChange: 1,
        lovePointsChange: lovePoints,
        heightChange: growthAmount,
        happinessChange: happinessBoost,
      );

      // Update village-level stats
      await _villageService.updateVillageStats(
        villageId: villageId,
        lovePointsIncrement: lovePoints,
      );

      // Check if tree just got completed
      final newMemoryCount = memoryCount + 1;
      String message =
          '${emotion.icon} Memory added! Tree grew ${growthAmount.toStringAsFixed(1)} units!';
      bool isCompleted = false;

      if (newMemoryCount >= LoveTree.MAX_MEMORIES) {
        message =
            '🎉 Congratulations! Tree completed with 60 memories!\n'
            'Your tree is now part of your village history. 💚';
        isCompleted = true;
      } else if (newMemoryCount >= 55) {
        // Give a heads up when close to completion
        final remaining = LoveTree.MAX_MEMORIES - newMemoryCount;
        message =
            '${emotion.icon} Memory added! Only $remaining more to complete this tree!';
      }

      return MemoryResult(
        success: true,
        message: message,
        treeCompleted: isCompleted,
        newStage: LoveTree.calculateStage(newMemoryCount, true),
      );
    } catch (e) {
      return MemoryResult(
        success: false,
        message: 'Error adding memory: ${e.toString()}',
      );
    }
  }

  /// Delete a memory (only the creator can delete)
  Future<MemoryResult> deleteMemory({
    required String villageId,
    required String treeId,
    required String memoryId,
    required String userId,
  }) async {
    try {
      final memoryRef = _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId)
          .collection('memories')
          .doc(memoryId);

      final memoryDoc = await memoryRef.get();
      if (!memoryDoc.exists) {
        return MemoryResult(
          success: false,
          message: 'Memory not found',
        );
      }

      // Check if user owns the memory
      final memoryData = memoryDoc.data()!;
      if (memoryData['addedBy'] != userId) {
        return MemoryResult(
          success: false,
          message: 'You can only delete your own memories',
        );
      }

      // Get emotion for calculating points to deduct
      final emotionName = memoryData['emotion'];
      final emotion = MemoryEmotion.values.firstWhere(
        (e) => e.name == emotionName,
        orElse: () => MemoryEmotion.happy,
      );

      // Delete the memory
      await memoryRef.delete();

      // Update tree stats (reverse the growth)
      await _treeService.updateTreeStats(
        villageId: villageId,
        treeId: treeId,
        memoryCountChange: -1,
        lovePointsChange: -_calculateLovePoints(emotion),
        heightChange: -_calculateGrowth(emotion),
        happinessChange: -_calculateHappinessBoost(emotion),
      );

      // Update village stats
      await _villageService.updateVillageStats(
        villageId: villageId,
        lovePointsIncrement: -_calculateLovePoints(emotion),
      );

      return MemoryResult(
        success: true,
        message: 'Memory deleted successfully',
      );
    } catch (e) {
      return MemoryResult(
        success: false,
        message: 'Error deleting memory: ${e.toString()}',
      );
    }
  }

  /// Get a specific memory by ID
  Future<Memory?> getMemory(
    String villageId,
    String treeId,
    String memoryId,
  ) async {
    try {
      final doc = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId)
          .collection('memories')
          .doc(memoryId)
          .get();

      if (!doc.exists) return null;
      return Memory.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Get memories by specific user
  Future<List<Memory>> getMemoriesByUser(
    String villageId,
    String treeId,
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId)
          .collection('memories')
          .where('addedBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Memory.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get memories by emotion type
  Future<List<Memory>> getMemoriesByEmotion(
    String villageId,
    String treeId,
    MemoryEmotion emotion,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId)
          .collection('memories')
          .where('emotion', isEqualTo: emotion.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Memory.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get memory statistics for a tree
  Future<MemoryStats> getMemoryStats(String villageId, String treeId) async {
    try {
      final snapshot = await _firestore
          .collection('villages')
          .doc(villageId)
          .collection('trees')
          .doc(treeId)
          .collection('memories')
          .get();

      final memories = snapshot.docs
          .map((doc) => Memory.fromFirestore(doc.data(), doc.id))
          .toList();

      // Count emotions
      final emotionCounts = <MemoryEmotion, int>{};
      for (var emotion in MemoryEmotion.values) {
        emotionCounts[emotion] = 0;
      }

      for (var memory in memories) {
        emotionCounts[memory.emotion] =
            (emotionCounts[memory.emotion] ?? 0) + 1;
      }

      // Count by user
      final userCounts = <String, int>{};
      for (var memory in memories) {
        userCounts[memory.addedBy] = (userCounts[memory.addedBy] ?? 0) + 1;
      }

      return MemoryStats(
        totalMemories: memories.length,
        emotionCounts: emotionCounts,
        userCounts: userCounts,
        mostUsedEmotion: emotionCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key,
      );
    } catch (e) {
      return MemoryStats(
        totalMemories: 0,
        emotionCounts: {},
        userCounts: {},
        mostUsedEmotion: MemoryEmotion.happy,
      );
    }
  }

  // ========================================================================
  // GROWTH CALCULATION METHODS
  // ========================================================================

  /// Calculate tree growth amount based on memory emotion
  double _calculateGrowth(MemoryEmotion emotion) {
    switch (emotion) {
      case MemoryEmotion.love:
        return 8.0;
      case MemoryEmotion.joyful:
        return 7.0;
      case MemoryEmotion.happy:
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

  /// Calculate happiness boost based on memory emotion
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

  /// Calculate love points earned based on memory emotion
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

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Get current month key in format: YYYY_MM
  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// RESULT & STATS CLASSES
// ============================================================================

/// Result object returned by memory operations
class MemoryResult {
  final bool success;
  final String message;
  final bool treeCompleted;
  final TreeStage? newStage;

  MemoryResult({
    required this.success,
    required this.message,
    this.treeCompleted = false,
    this.newStage,
  });
}

/// Statistics about memories in a tree
class MemoryStats {
  final int totalMemories;
  final Map<MemoryEmotion, int> emotionCounts;
  final Map<String, int> userCounts;
  final MemoryEmotion mostUsedEmotion;

  MemoryStats({
    required this.totalMemories,
    required this.emotionCounts,
    required this.userCounts,
    required this.mostUsedEmotion,
  });

  /// Get percentage of a specific emotion
  double getEmotionPercentage(MemoryEmotion emotion) {
    if (totalMemories == 0) return 0.0;
    return ((emotionCounts[emotion] ?? 0) / totalMemories) * 100;
  }

  /// Get balance between partners (0.5 = perfectly balanced)
  double getPartnerBalance() {
    if (userCounts.isEmpty || totalMemories == 0) return 0.5;

    final values = userCounts.values.toList();
    if (values.length < 2) return 0.5;

    return values[0] / totalMemories;
  }
}
