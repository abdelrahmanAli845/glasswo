import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/daily_record.dart';
import '../../models/product.dart';
import '../../models/product_model.dart';
import '../../models/shape.dart';
import '../../models/worker.dart';
import '../../service/daily_service.dart';
import 'worker_card.dart';
import '../../providers/product_provider.dart';
import '../../providers/model_provider.dart';
import '../../providers/shape_provider.dart';
import '../../providers/worker_provider.dart';

class DailyScreen extends StatefulWidget {
@override
State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
DateTime selectedDate = DateTime.now();
Map<String, DailyRecord> records = {};
bool isLoaded = false;
@override
void initState() {
super.initState();
Future.microtask(() {
context.read<ProductProvider>().listen();
context.read<ModelProvider>().listenAll();
context.read<ShapeProvider>().listenAll();
context.read<WorkerProvider>().listen();
loadLocal(); // 🔥
});
}
Future<void> saveLocal() async {
 final prefs = await SharedPreferences.getInstance();

 final data = records.map(
      (key, value) => MapEntry(key, value.toLocalJson()),
 );

 final key = 'daily_${selectedDate.toIso8601String()}';

 await prefs.setString(key, jsonEncode(data)); // ✅ حفظ
}
Future<void> loadLocal() async {
 final prefs = await SharedPreferences.getInstance();

 final key = 'daily_${selectedDate.toIso8601String()}';

 final json = prefs.getString(key); // ✅ قراءة

 if (json == null) {
  setState(() {
   isLoaded = true;
  });
  return;
 }

 final decoded = jsonDecode(json) as Map<String, dynamic>;

 records = decoded.map(
      (key, value) => MapEntry(
   key,
   DailyRecord.fromLocalJson(value),
  ),
 );

 setState(() {
  isLoaded = true;
 });
}
Widget build(BuildContext context) {
if (!isLoaded) {
return Scaffold(
body: Center(child: CircularProgressIndicator()),
);
}
final workers = context.watch<WorkerProvider>().workers;
final products = context.watch<ProductProvider>().products;
final models = context.watch<ModelProvider>().models;
final shapes = context.watch<ShapeProvider>().shapes;

return Scaffold(
appBar: AppBar(
title: Text("إدارة اليوم"),
actions: [
IconButton(
icon: Icon(Icons.calendar_today),
onPressed: pickDate,
)
],
),
body: ListView(
children: [
...workers.map((w) {
if (isLoaded) {
records.putIfAbsent(
w.id,
() => DailyRecord(
id: '',
workerRef: FirebaseFirestore.instance.collection('workers').doc(w.id),
date: selectedDate,
),
);
}

return WorkerCard(
worker: w,
record: records[w.id]!,
products: products,
models: models,
shapes: shapes,
onChanged: () {
setState(() {});
saveLocal(); // 🔥
},            );
}).toList(),
SizedBox(height: 20.h),
Padding(
padding:  EdgeInsets.all(12.w),
child: ElevatedButton(
onPressed: saveAll,
child: Text("💾 حفظ اليوم"),
),
)
],
),
);

}

void pickDate() async {
final picked = await showDatePicker(
context: context,
initialDate: selectedDate,
firstDate: DateTime(2023),
lastDate: DateTime(2030),
);

if (picked != null) {
setState(() {
selectedDate = picked;
records.clear();
});
}

}

void saveAll() async {
final confirm = await showDialog(
context: context,
builder: (_) => AlertDialog(
title: Text("تأكيد"),
content: Text("هل تريد حفظ اليوم؟"),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: Text("إلغاء"),
),
ElevatedButton(
onPressed: () => Navigator.pop(context, true),
child: Text("تأكيد"),
),
],
),
);
 if (confirm != true) return;

showDialog(
context: context,
barrierDismissible: false,
builder: (_) => Center(child: CircularProgressIndicator()),
);

final service = DailyService();

for (var r in records.values) {
await service.save(r);
}

Navigator.pop(context); // يقفل اللودينج

setState(() {
records.clear(); // 🔥 يبدأ يوم جديد
selectedDate = DateTime.now();
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text("تم حفظ اليوم ✅")),
);

}}
