import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bouns.dart';

class SettingsService {
  final _db = FirebaseFirestore.instance;

  DocumentReference get _doc => _db.collection('settings').doc('app');

  Stream<AppSettings> stream() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists) {
        return AppSettings(
          qualityBonus: 25,
          productionBonus: 25,
          commitmentBonus: 25,
        );
      }
      return AppSettings.fromMap(snap.data() as Map<String, dynamic>);
    });
  }

  Future<void> save(AppSettings settings) async {
    await _doc.set(settings.toMap());
  }
}