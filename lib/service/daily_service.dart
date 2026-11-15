import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_record.dart';

class DailyService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('daily_records');
  Future<List<DailyRecord>> getAll() async {
    final result = await _col.get();
    return dedupe(result.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<DailyRecord>> streamAll() {
    return _col.snapshots().map((snap) => dedupe(snap.docs
        .map((doc) => DailyRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList()));
  }
  Future<List<DailyRecord>> getByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final result = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return dedupe(result.docs.map((e) {
      return DailyRecord.fromMap(e.id, e.data() as Map<String, dynamic>);
    }).toList());
  }
  /// One fixed document ID per worker per day.
  static String docIdFor(String workerId, DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${workerId}_${date.year}${two(date.month)}${two(date.day)}';
  }

  /// Keeps one record per worker per day: the most recently saved copy.
  /// Older app versions could save the same day several times.
  static List<DailyRecord> dedupe(List<DailyRecord> records) {
    final byDay = <String, DailyRecord>{};
    for (final r in records) {
      final key = docIdFor(r.workerRef.id, r.date);
      final current = byDay[key];
      if (current == null || _isNewer(r, current)) byDay[key] = r;
    }
    return byDay.values.toList();
  }

  static bool _isNewer(DailyRecord a, DailyRecord b) {
    if (a.updatedAt == null) return false;
    if (b.updatedAt == null) return true;
    return a.updatedAt!.isAfter(b.updatedAt!);
  }

  /// Saves the record under its fixed ID, so saving again (retry, offline
  /// queue, a second device) overwrites the same document instead of adding a copy.
  ///
  /// Returns false when the server hasn't confirmed within [timeout]: the write
  /// stays queued in Firestore's offline cache and is sent when the connection returns.
  Future<bool> save(DailyRecord record, {Duration timeout = const Duration(seconds: 15)}) async {
    if (record.id.isEmpty) {
      record.id = docIdFor(record.workerRef.id, record.date);
    }
    record.updatedAt = DateTime.now();
    try {
      await _col.doc(record.id).set(record.toJson()).timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }
  Stream<List<DailyRecord>> streamByDate(DateTime date) {
    final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    return _col
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snap) => dedupe(snap.docs
            .map((doc) => DailyRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList()));
  }

  Future<List<DailyRecord>> getByDate(DateTime date) async {
    final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final end = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    final result = await _col
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    return dedupe(result.docs.map((doc) {
      return DailyRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList());
  }
}