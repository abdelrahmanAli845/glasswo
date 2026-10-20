import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_wo/models/daily_record.dart';
import 'package:glass_wo/models/production_item.dart';
import 'package:glass_wo/models/shape.dart';
import 'package:glass_wo/models/work_session.dart';
import 'package:glass_wo/models/worker.dart';
import 'package:glass_wo/providers/bouns_provider.dart';
import 'package:glass_wo/service/salary_calculator.dart';

// ignore: subtype_of_sealed_class
class _FakeRef extends Fake implements DocumentReference<Map<String, dynamic>> {
  _FakeRef(this.id);

  @override
  final String id;
}

void main() {
  // 200 / 10 = 20 per hour
  final worker = Worker(id: 'w1', name: 'A', dailySalary: 200, workHours: 10);
  final fixedWorker = Worker(id: 'w2', name: 'B', dailySalary: 200, workHours: 10, hasBonus: false);
  final bonus = BonusProvider(); // 25 / 25 / 25
  final day = DateTime(2026, 5, 3);

  DailyRecord record({
    List<WorkSession> sessions = const [],
    bool isAbsent = false,
    bool onTime = false,
    int rating = 0,
    String deductionType = 'none',
    List<ProductionItem> productions = const [],
  }) {
    return DailyRecord(
      id: '',
      workerRef: _FakeRef('w1'),
      date: day,
      sessions: sessions,
      isAbsent: isAbsent,
      onTime: onTime,
      rating: rating,
      deductionType: deductionType,
      productions: productions,
    );
  }

  double calc(Worker w, DailyRecord r, [List<Shape> shapes = const []]) =>
      SalaryCalculator.calculate(worker: w, record: r, bonus: bonus, shapes: shapes);

  test('absent worker gets nothing', () {
    expect(calc(worker, record(isAbsent: true, onTime: true)), 0);
  });

  test('base daily salary', () {
    expect(calc(worker, record()), 200);
  });

  test('overtime is paid double, including overnight sessions', () {
    final r = record(sessions: [
      WorkSession(checkIn: DateTime(2026, 5, 3, 20), checkOut: DateTime(2026, 5, 4, 8)),
    ]);
    expect(SalaryCalculator.workedHours(r), 12);
    expect(calc(worker, r), 200 + 2 * 20 * 2);
  });

  test('deductions', () {
    expect(calc(worker, record(deductionType: 'hour')), 180);
    expect(calc(worker, record(deductionType: 'half')), 100);
    expect(calc(worker, record(deductionType: 'full')), 0);
  });

  test('quality and commitment bonuses', () {
    expect(calc(worker, record(rating: 5)), 225);
    expect(calc(worker, record(rating: 1)), 205);
    expect(calc(worker, record(onTime: true)), 225);
  });

  test('production bonus only when target is reached', () {
    final shapes = [Shape(id: 's1', name: 'S', target: 10, modelRef: _FakeRef('m1'))];
    ProductionItem item(int qty) => ProductionItem(
          productRef: _FakeRef('p1'),
          modelRef: _FakeRef('m1'),
          shapeRef: _FakeRef('s1'),
          quantity: qty,
        );
    expect(calc(worker, record(productions: [item(10)]), shapes), 225);
    expect(calc(worker, record(productions: [item(9)]), shapes), 200);
  });

  test('fixed-salary worker gets no bonuses but still gets deductions', () {
    expect(calc(fixedWorker, record(rating: 5, onTime: true)), 200);
    expect(calc(fixedWorker, record(deductionType: 'quarter')), 150);
  });

  test('zero work hours does not produce infinity', () {
    final w = Worker(id: 'w3', name: 'C', dailySalary: 200, workHours: 0);
    expect(calc(w, record(deductionType: 'hour')).isFinite, isTrue);
  });
}
