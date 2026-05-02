import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_record.dart';
import '../models/production_item.dart';

class DailyService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('daily_records');
  Future<List<DailyRecord>> getAll() async {
    final result = await _col.get();

    print("🔥 عدد الـ records: ${result.docs.length}");
    return result.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      print("🔥 عدد الـ worker: ${data['workerRef']}");

      return DailyRecord(
        id: doc.id,
        workerRef: data['workerRef'] ?? '',
        date: data['date'].toDate(),
        checkIn: data['checkIn']?.toDate(),
        checkOut: data['checkOut']?.toDate(),
        onTime: data['onTime'] ?? false,
        rating: data['rating'] ?? 0,
        deductionType: data['deductionType'] ?? 'none', // 🔥 مهم
        productions: (data['productions'] as List? ?? [])
            .map((e) => ProductionItem.fromMap(e))
            .toList(),
      );
    }).toList();
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
    final col = FirebaseFirestore.instance.collection('daily_records');

    if (record.id.isEmpty) {
      // ➕ إضافة
      final doc = await col.add(record.toJson());
      record.id = doc.id; // 🔥 احفظ الاي دي
    } else {
      // 🔁 تعديل
      await col.doc(record.id).update(record.toJson());
    }
  }
  Future<List<DailyRecord>> getByDate(DateTime date) async {
    final result = await _col
        .where('date', isEqualTo: DateTime(date.year, date.month, date.day))
        .get();

    return result.docs.map((doc) {
      final data = doc.data() as Map;

      return DailyRecord(
        id: doc.id,
        workerRef: data['workerRef'],
        date: data['date'].toDate(),
        checkIn: data['checkIn']?.toDate(),
        checkOut: data['checkOut']?.toDate(),
        onTime: data['onTime'] ?? false,
        rating: data['rating'] ?? 0,
        productions: (data['productions'] as List)
            .map((e) => ProductionItem.fromMap(e))
            .toList(),
      );
    }).toList();
  }
}