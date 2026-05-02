import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BonusProvider extends ChangeNotifier {

  double qualityBonus = 25;
  double productionBonus = 25;
  double commitmentBonus = 25;

  /// 🔄 تحميل من الميموري
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString('bonus_settings');

    if (json == null) return;

    final data = jsonDecode(json);

    qualityBonus = (data['quality'] ?? 25).toDouble();
    productionBonus = (data['production'] ?? 25).toDouble();
    commitmentBonus = (data['commitment'] ?? 25).toDouble();

    notifyListeners();
  }

  /// 💾 حفظ
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'quality': qualityBonus,
      'production': productionBonus,
      'commitment': commitmentBonus,
    };

    await prefs.setString('bonus_settings', jsonEncode(data));
  }

  /// 🎯 تعديل القيم
  Future<void> setBonuses({
    required double quality,
    required double production,
    required double commitment,
  }) async {

    qualityBonus = quality;
    productionBonus = production;
    commitmentBonus = commitment;

    await save();

    notifyListeners();
  }
}