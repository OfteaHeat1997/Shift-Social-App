// lib/services/statement_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift_application/models/statement.dart';

class StatementService {
  final _db = FirebaseFirestore.instance;

  Future<List<Statement>> fetchAll() async {
    final snap = await _db.collection('statements').get();
    return snap.docs.map((d) => Statement.fromDoc(d)).toList();
  }
}
