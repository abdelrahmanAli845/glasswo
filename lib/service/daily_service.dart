import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_record.dart';

class DailyService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('daily_records');
  Future<List<DailyRecord>> getAll() async {
    final result = await _col.get();
    return result.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }
  Future<List<DailyRecord>> getByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final result = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return result.docs.map((e) {
      return DailyRecord.fromMap(e.id, e.data() as Map<String, dynamic>);
    }).toList();
  }
  Future<void> save(DailyRecord record) async {
    if (record.id.isEmpty) {
      final doc = await _col.add(record.toJson());
      record.id = doc.id;
    } else {
      await _col.doc(record.id).update(record.toJson());
    }
  }
  Future<List<DailyRecord>> getByDate(DateTime date) async {
    final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    final result = await _col
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    return result.docs.map((doc) {
      return DailyRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }
}