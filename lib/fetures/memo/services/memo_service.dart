import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:memora/fetures/memo/model/memo.dart';

class MemoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add new memo
  Future<Memo> addMemo({
    required String treeId,
    required String coupleId,
    required String userId,
    required String content,
    required EmotionType emotion,
    required MemoType type,
    File? mediaFile,
  }) async {
    String? mediaUrl;

    // Upload media if provided
    if (mediaFile != null) {
      mediaUrl = await _uploadMedia(coupleId, mediaFile);
    }

    final memo = Memo(
      id: _firestore.collection('memos').doc().id,
      treeId: treeId,
      coupleId: coupleId,
      addedBy: userId,
      content: content,
      emotion: emotion,
      type: type,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('memos').doc(memo.id).set(memo.toMap());
    return memo;
  }

  // Upload media to Firebase Storage
  Future<String> _uploadMedia(String coupleId, File file) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'memos/$coupleId/$timestamp.jpg';

    final ref = _storage.ref().child(fileName);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Get memos for a tree
  Stream<List<Memo>> getMemosForTree(String treeId) {
    return _firestore
        .collection('memos')
        .where('treeId', isEqualTo: treeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Memo.fromMap(doc.data())).toList(),
        );
  }

  // Add reaction to memo
  Future<void> addReaction(String memoId, String userId, String emoji) async {
    final reaction = Reaction(
      userId: userId,
      emoji: emoji,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('memos').doc(memoId).update({
      'reactions': FieldValue.arrayUnion([reaction.toMap()]),
    });
  }

  // Delete memo
  Future<void> deleteMemo(String memoId) async {
    await _firestore.collection('memos').doc(memoId).delete();
  }
}
