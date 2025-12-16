import 'package:cloud_firestore/cloud_firestore.dart';

class Reflection {
  final String id;
  final String who;
  final String? emoji;
  final String? opinionChanged;
  final String? whatWasDiscussed;
  final String? audioPath;
  final DateTime timestamp;
  final String statementId;
  final String userId;

  Reflection({
    required this.id,
    required this.who,
    this.emoji,
    this.opinionChanged,
    this.whatWasDiscussed,
    this.audioPath,
    required this.timestamp,
    required this.statementId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'who': who,
      'emoji': emoji,
      'opinionChanged': opinionChanged,
      'whatWasDiscussed': whatWasDiscussed,
      'audioPath': audioPath,
      'timestamp': timestamp,
      'statementId': statementId,
      'userId': userId,
    };
  }

  factory Reflection.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reflection(
      id: doc.id,
      who: data['who'] ?? '',
      emoji: data['emoji'],
      opinionChanged: data['opinionChanged'],
      whatWasDiscussed: data['whatWasDiscussed'],
      audioPath: data['audioPath'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      statementId: data['statementId'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}