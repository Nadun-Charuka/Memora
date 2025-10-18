import 'package:cloud_firestore/cloud_firestore.dart';

enum EmotionType { happy, sad, nostalgic, grateful, excited, loving }

enum MemoType { text, photo, voice, emoji }

class Memo {
  final String id;
  final String treeId;
  final String coupleId;
  final String addedBy; // userId
  final String content;
  final EmotionType emotion;
  final MemoType type;
  final String? mediaUrl;
  final DateTime createdAt;
  final List<Reaction> reactions;

  Memo({
    required this.id,
    required this.treeId,
    required this.coupleId,
    required this.addedBy,
    required this.content,
    required this.emotion,
    required this.type,
    this.mediaUrl,
    required this.createdAt,
    this.reactions = const [],
  });

  // Calculate points based on emotion
  int getPoints() {
    switch (emotion) {
      case EmotionType.happy:
      case EmotionType.loving:
        return 5;
      case EmotionType.grateful:
      case EmotionType.excited:
        return 4;
      case EmotionType.nostalgic:
        return 3;
      case EmotionType.sad:
        return -2;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'treeId': treeId,
      'coupleId': coupleId,
      'addedBy': addedBy,
      'content': content,
      'emotion': emotion.name,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'reactions': reactions.map((r) => r.toMap()).toList(),
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'],
      treeId: map['treeId'],
      coupleId: map['coupleId'],
      addedBy: map['addedBy'],
      content: map['content'],
      emotion: EmotionType.values.byName(map['emotion']),
      type: MemoType.values.byName(map['type']),
      mediaUrl: map['mediaUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reactions:
          (map['reactions'] as List?)
              ?.map((r) => Reaction.fromMap(r))
              .toList() ??
          [],
    );
  }
}

class Reaction {
  final String userId;
  final String emoji;
  final DateTime timestamp;

  Reaction({
    required this.userId,
    required this.emoji,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'emoji': emoji,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory Reaction.fromMap(Map<String, dynamic> map) => Reaction(
    userId: map['userId'],
    emoji: map['emoji'],
    timestamp: (map['timestamp'] as Timestamp).toDate(),
  );
}
