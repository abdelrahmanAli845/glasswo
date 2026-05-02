import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/bouns_provider.dart';

class BonusScreen extends StatefulWidget {
  const BonusScreen({super.key});

  @override
  State<BonusScreen> createState() => _BonusScreenState();
}

class _BonusScreenState extends State<BonusScreen> {

  final qualityController = TextEditingController();
  final productionController = TextEditingController();
  final commitmentController = TextEditingController();

  bool isLoaded = false;

  @override
  void initState() {
    super.initState();

    /// ✅ الحل هنا
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BonusProvider>();

      qualityController.text = provider.qualityBonus.toString();
      productionController.text = provider.productionBonus.toString();
      commitmentController.text = provider.commitmentBonus.toString();

      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙️ إعدادات الحوافز"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🎯 حافز الجودة
            TextField(
              controller: qualityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "حافز الجودة",
              ),
            ),

            const SizedBox(height: 12),

            /// 📦 حافز الإنتاج
            TextField(
              controller: productionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "حافز الإنتاج",
              ),
            ),

            const SizedBox(height: 12),

            /// ⏰ حافز الالتزام
            TextField(
              controller: commitmentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "حافز الالتزام",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final provider = context.read<BonusProvider>();

                provider.setBonuses(
                  quality: double.tryParse(qualityController.text) ?? 0,
                  production: double.tryParse(productionController.text) ?? 0,
                  commitment: double.tryParse(commitmentController.text) ?? 0,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم الحفظ ✅")),
                );
              },
              child: const Text("💾 حفظ"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    qualityController.dispose();
    productionController.dispose();
    commitmentController.dispose();
    super.dispose();
  }
}