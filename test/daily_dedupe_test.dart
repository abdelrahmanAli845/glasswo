import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_wo/models/daily_record.dart';
import 'package:glass_wo/service/daily_service.dart';

// ignore: subtype_of_sealed_class
class _FakeRef extends Fake implements DocumentReference<Map<String, dynamic>> {
  _FakeRef(this.id);

  @override
  final String id;
}

DailyRecord _rec(String id, String worker, DateTime date, {DateTime? updatedAt, double salary = 100}) {
  return DailyRecord(
    id: id,
    workerRef: _FakeRef(worker),
    date: date,
    updatedAt: updatedAt,
    totalSalary: salary,
  );
}

void main() {
  test('fixed doc id per worker per day, ignoring time of day', () {
    expect(DailyService.docIdFor('w1', DateTime(2026, 11, 4, 17, 22)), 'w1_20261104');
    expect(
      DailyService.docIdFor('w1', DateTime(2026, 11, 4, 0, 0)),
      DailyService.docIdFor('w1', DateTime(2026, 11, 4, 23, 59)),
    );
  });

  test('dedupe keeps one record per worker per day', () {
    final day = DateTime(2026, 11, 14, 17, 22);
    final records = [
      for (var i = 0; i < 7; i++) _rec('a$i', 'w1', day),
      _rec('b', 'w2', day),
      _rec('c', 'w1', DateTime(2026, 11, 13, 9)),
    ];
    final result = DailyService.dedupe(records);
    expect(result.length, 3);
    final total = result.fold(0.0, (s, r) => s + r.totalSalary);
    expect(total, 300);
  });

  test('dedupe prefers the most recently saved copy', () {
    final day = DateTime(2026, 11, 14);
    final records = [
      _rec('old', 'w1', day, salary: 100),
      _rec('newest', 'w1', day, updatedAt: DateTime(2026, 11, 14, 18), salary: 131),
      _rec('newer', 'w1', day, updatedAt: DateTime(2026, 11, 14, 16), salary: 120),
    ];
    final result = DailyService.dedupe(records);
    expect(result.single.id, 'newest');
  });
}
