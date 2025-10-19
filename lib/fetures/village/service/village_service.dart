import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class VillageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Create a new village/couple
  Future<Map<String, dynamic>> createVillage({
    required String userId,
    required String userName,
    required String villageName,
    required String partnerName,
  }) async {
    try {
      // Generate unique invite code
      String inviteCode;
      bool codeExists = true;

      // Ensure code is unique
      do {
        inviteCode = _generateInviteCode();
        final existing = await _firestore
            .collection('couples')
            .where('inviteCode', isEqualTo: inviteCode)
            .get();
        codeExists = existing.docs.isNotEmpty;
      } while (codeExists);

      // Create couple document
      final coupleRef = _firestore.collection('couples').doc();

      await coupleRef.set({
        'coupleId': coupleRef.id,
        'villageName': villageName,
        'partner1Id': userId,
        'partner1Name': userName,
        'partner2Id': null,
        'partner2Name': partnerName,
        'inviteCode': inviteCode,
        'status': 'pending', // pending, active
        'createdAt': FieldValue.serverTimestamp(),
        'totalLovePoints': 0,
        'currentStreak': 0,
        'lastInteraction': FieldValue.serverTimestamp(),
      });

      // Update user document with coupleId
      await _firestore.collection('users').doc(userId).update({
        'coupleId': coupleRef.id,
        'role': 'creator',
      });

      // Create first tree for current month
      await _createMonthlyTree(coupleRef.id);

      return {
        'success': true,
        'coupleId': coupleRef.id,
        'inviteCode': inviteCode,
        'message': 'Village created successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create village: ${e.toString()}',
      };
    }
  }

  // Join existing village with invite code
  Future<Map<String, dynamic>> joinVillage({
    required String userId,
    required String userName,
    required String inviteCode,
  }) async {
    try {
      // Find couple with invite code
      final coupleQuery = await _firestore
          .collection('couples')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (coupleQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid invite code. Please check and try again.',
        };
      }

      final coupleDoc = coupleQuery.docs.first;
      final coupleData = coupleDoc.data();

      // Check if village is already complete
      if (coupleData['partner2Id'] != null) {
        return {
          'success': false,
          'message': 'This village is already complete.',
        };
      }

      // Check if user is trying to join their own village
      if (coupleData['partner1Id'] == userId) {
        return {
          'success': false,
          'message': 'You cannot join your own village.',
        };
      }

      // Update couple document with partner 2
      await coupleDoc.reference.update({
        'partner2Id': userId,
        'partner2Name': userName,
        'status': 'active',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update user document with coupleId
      await _firestore.collection('users').doc(userId).update({
        'coupleId': coupleDoc.id,
        'role': 'joiner',
      });

      return {
        'success': true,
        'coupleId': coupleDoc.id,
        'message': 'Successfully joined the village!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to join village: ${e.toString()}',
      };
    }
  }

  // Create initial tree for the current month
  Future<void> _createMonthlyTree(String coupleId) async {
    final now = DateTime.now();
    final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';

    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('trees')
        .doc(monthKey)
        .set({
          'treeId': monthKey,
          'name': _getMonthTreeName(now.month),
          'type': _getMonthTreeType(now.month),
          'level': 1,
          'height': 10.0,
          'happiness': 1.0,
          'health': 1.0,
          'lovePoints': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastInteraction': FieldValue.serverTimestamp(),
          'stage': 'notPlanted',
          'memoryCount': 0,
          'isPlanted': false,
          'plantedBy': [], // Track who has planted
        });
  }

  // Get month-specific tree name
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

  // Get month-specific tree type
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

  // Get couple data by user ID
  Future<Map<String, dynamic>?> getCoupleByUserId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final coupleId = userDoc.data()?['coupleId'];

      if (coupleId == null) return null;

      final coupleDoc = await _firestore
          .collection('couples')
          .doc(coupleId)
          .get();

      if (!coupleDoc.exists) return null;

      return coupleDoc.data();
    } catch (e) {
      return null;
    }
  }

  // Get current month's tree
  Future<Map<String, dynamic>?> getCurrentTree(String coupleId) async {
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';

      final treeDoc = await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('trees')
          .doc(monthKey)
          .get();

      if (!treeDoc.exists) {
        // Create tree if it doesn't exist
        await _createMonthlyTree(coupleId);
        return await getCurrentTree(coupleId);
      }

      return treeDoc.data();
    } catch (e) {
      return null;
    }
  }

  // Get invite code for a couple
  Future<String?> getInviteCode(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final coupleId = userDoc.data()?['coupleId'];

      if (coupleId == null) return null;

      final coupleDoc = await _firestore
          .collection('couples')
          .doc(coupleId)
          .get();

      return coupleDoc.data()?['inviteCode'];
    } catch (e) {
      return null;
    }
  }
}
