import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("الوضع الليلي"),
            subtitle: const Text("تحويل الشاشة للوضع الداكن"),
            value: settings.darkMode,
            onChanged: (v) => context.read<SettingsProvider>().setDarkMode(v),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
