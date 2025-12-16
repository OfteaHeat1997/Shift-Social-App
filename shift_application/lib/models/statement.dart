import 'package:cloud_firestore/cloud_firestore.dart';

class Statement {
  final String id;
  final String text;
  final String agreeColor;
  final String neutralColor;
  final String disagreeColor;

  Statement({
    required this.id,
    required this.text,
    required this.agreeColor,
    required this.neutralColor,
    required this.disagreeColor,
  });

  factory Statement.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Statement(
      id: doc.id,
      text: data['text'] ?? '',
      agreeColor: data['agreeColor'] ?? '#36EAB7',
      neutralColor: data['neutralColor'] ?? '#FFD600',
      disagreeColor: data['disagreeColor'] ?? '#F64060',
    );
  }
}
