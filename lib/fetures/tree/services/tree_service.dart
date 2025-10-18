import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memora/fetures/tree/model/love_tree.dart';

class TreeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current month's tree for a couple
  Stream<LoveTree?> getCurrentTree(String coupleId) {
    final now = DateTime.now();
    final monthYear = '${now.year}_${now.month.toString().padLeft(2, '0')}';

    return _firestore
        .collection('trees')
        .where('coupleId', isEqualTo: coupleId)
        .where('monthYear', isEqualTo: monthYear)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return LoveTree.fromMap(snapshot.docs.first.data());
        });
  }

  // Create new tree for the month
  Future<LoveTree> createMonthlyTree(String coupleId) async {
    final now = DateTime.now();
    final monthYear = '${now.year}_${now.month.toString().padLeft(2, '0')}';
    final monthName = _getMonthName(now.month);

    final tree = LoveTree(
      id: _firestore.collection('trees').doc().id,
      coupleId: coupleId,
      name: '$monthName Love Tree',
      type: _getSeasonalTreeType(now.month),
      createdAt: now,
      monthYear: monthYear,
      lastInteraction: now,
    );

    await _firestore.collection('trees').doc(tree.id).set(tree.toMap());
    return tree;
  }

  // Update tree after memo addition
  Future<void> updateTreeGrowth(String treeId, int points) async {
    final treeRef = _firestore.collection('trees').doc(treeId);
    final treeDoc = await treeRef.get();

    if (!treeDoc.exists) return;

    final tree = LoveTree.fromMap(treeDoc.data()!);
    tree.addLovePoints(points);
    tree.grow(points * 0.5); // Growth is proportional to points

    await treeRef.update(tree.toMap());
  }

  // Check and apply decay
  Future<void> checkTreeHealth(String treeId) async {
    final treeRef = _firestore.collection('trees').doc(treeId);
    final treeDoc = await treeRef.get();

    if (!treeDoc.exists) return;

    final tree = LoveTree.fromMap(treeDoc.data()!);
    tree.decay();

    await treeRef.update({'health': tree.health});
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getSeasonalTreeType(int month) {
    if (month >= 3 && month <= 5) return 'SakuraTree'; // Spring
    if (month >= 6 && month <= 8) return 'MapleTree'; // Summer
    if (month >= 9 && month <= 11) return 'OakTree'; // Fall
    return 'PineTree'; // Winter
  }

  // Get all trees for couple (for village view)
  Stream<List<LoveTree>> getAllTrees(String coupleId) {
    return _firestore
        .collection('trees')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => LoveTree.fromMap(doc.data())).toList(),
        );
  }
}
