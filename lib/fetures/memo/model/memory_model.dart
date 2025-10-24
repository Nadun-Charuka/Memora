import 'package:cloud_firestore/cloud_firestore.dart';

enum MemoryEmotion {
  happy,
  excited,
  joyful,
  grateful,
  love,
  sad,
  nostalgic,
  peaceful,
  awful;

  String get icon {
    switch (this) {
      case MemoryEmotion.happy:
        return '🌸';
      case MemoryEmotion.excited:
        return '🐦';
      case MemoryEmotion.joyful:
        return '🍎';
      case MemoryEmotion.grateful:
        return '⭐';
      case MemoryEmotion.love:
        return '❤️';
      case MemoryEmotion.sad:
        return '💧';
      case MemoryEmotion.nostalgic:
        return '🦋';
      case MemoryEmotion.peaceful:
        return '🐰';
      case MemoryEmotion.awful:
        return '⛈️';
    }
  }
}

class Memory {
  final String id;
  final String content;
  final MemoryEmotion emotion;
  final String? photoUrl;
  final String addedBy;
  final String addedByName;
  final DateTime createdAt;
  final bool isHide;

  Memory({
    required this.id,
    required this.content,
    required this.emotion,
    this.photoUrl,
    required this.addedBy,
    required this.addedByName,
    required this.createdAt,
    this.isHide = false,
  });

  factory Memory.fromFirestore(Map<String, dynamic> data, String id) {
    return Memory(
      id: id,
      content: data['content'] ?? '',
      emotion: MemoryEmotion.values.firstWhere(
        (e) => e.name == data['emotion'],
        orElse: () => MemoryEmotion.happy,
      ),
      photoUrl: data['photoUrl'],
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isHide: data['isHide'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'emotion': emotion.name,
      'photoUrl': photoUrl,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'createdAt': FieldValue.serverTimestamp(),
      'isHide': isHide,
    };
  }
}
