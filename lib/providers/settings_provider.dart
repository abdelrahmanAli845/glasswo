import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool autoSave = false;
  bool darkMode = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    autoSave = prefs.getBool('autoSave') ?? false;
    darkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> setAutoSave(bool value) async {
    autoSave = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSave', value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }
}
