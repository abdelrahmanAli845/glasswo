import '../models/daily_record.dart';
import '../models/shape.dart';
import '../models/worker.dart';
import '../providers/bouns_provider.dart';

/// حساب يومية العامل — مستقل عن الشاشة عشان يتحسب قبل الحفظ
/// لكل العمال، مش بس اللي الكارت بتاعهم ظاهر.
class SalaryCalculator {
  static double hourRate(Worker worker) {
    if (worker.workHours <= 0) return 0;
    return worker.dailySalary / worker.workHours;
  }

  static double workedHours(DailyRecord record) {
    int totalMinutes = 0;
    for (final s in record.sessions) {
      if (s.checkIn == null || s.checkOut == null) continue;
      final diff = s.checkOut!.difference(s.checkIn!).inMinutes;
      if (diff > 0) totalMinutes += diff;
    }
    return totalMinutes / 60.0;
  }

  /// ساعات الأوفر تايم
  static double overtimeHours(Worker worker, DailyRecord record) {
    final extra = workedHours(record) - worker.workHours;
    return extra > 0 ? extra : 0;
  }

  static double overtimePay(Worker worker, DailyRecord record) {
    return overtimeHours(worker, record) * hourRate(worker) * 2;
  }

  static double calculate({
    required Worker worker,
    required DailyRecord record,
    required BonusProvider bonus,
    required List<Shape> shapes,
  }) {
    if (record.isAbsent) return 0;

    double total = worker.dailySalary + overtimePay(worker, record);

    /// 🎁 الحوافز (فقط لو مسموح)
    if (worker.hasBonus) {
      if (record.rating > 0 && record.rating <= 5) {
        final factor = 6 - record.rating;
        total += bonus.qualityBonus / factor;
      }

      if (record.onTime) {
        total += bonus.commitmentBonus;
      }

      for (final item in record.productions) {
        if (item.shapeRef == null || item.modelRef == null) continue;

        final matches = shapes.where(
          (s) => s.id == item.shapeRef!.id && s.modelRef.id == item.modelRef!.id,
        );
        if (matches.isNotEmpty && item.quantity >= matches.first.target) {
          total += bonus.productionBonus;
        }
      }
    }

    /// ❌ الخصومات (تشتغل دايماً)
    final rate = hourRate(worker);
    switch (record.deductionType) {
      case 'qurofhour':
        total -= rate / 4;
        break;
      case 'halfofhour':
        total -= rate / 2;
        break;
      case 'hour':
        total -= rate;
        break;
      case '2hours':
        total -= rate * 2;
        break;
      case 'quarter':
        total -= worker.dailySalary * 0.25;
        break;
      case 'half':
        total -= worker.dailySalary * 0.5;
        break;
      case 'full':
        total -= worker.dailySalary;
        break;
    }

    return total;
  }
}
