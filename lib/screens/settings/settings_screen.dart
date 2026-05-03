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
            title: const Text("الحفظ التلقائي"),
            subtitle: const Text("يحفظ التعديلات تلقائياً أثناء الإدخال"),
            value: settings.autoSave,
            onChanged: (v) => context.read<SettingsProvider>().setAutoSave(v),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
