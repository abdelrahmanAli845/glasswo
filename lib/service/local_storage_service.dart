import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_record.dart';

class LocalStorageService {
  static String _key(DateTime date, String workerId) =>
      'record_${date.year}_${date.month}_${date.day}_$workerId';

  Future<void> saveRecord(DailyRecord r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(r.date, r.workerRef.id), jsonEncode(r.toLocalJson()));
  }

  Future<DailyRecord?> loadRecord(DateTime date, String workerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(date, workerId));
    if (raw == null) return null;
    try {
      return DailyRecord.fromLocalJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearRecord(DateTime date, String workerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(date, workerId));
  }

  Future<void> clearDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'record_${date.year}_${date.month}_${date.day}_';
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
