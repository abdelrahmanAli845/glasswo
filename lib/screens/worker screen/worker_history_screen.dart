import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/daily_record.dart';
import '../../models/worker.dart';
import '../../service/daily_service.dart';

class WorkerHistoryScreen extends StatelessWidget {
  final Worker worker;
  const WorkerHistoryScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("سجل ${worker.name}")),
      body: StreamBuilder<List<DailyRecord>>(
        stream: DailyService().streamAll(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final records = snap.data!
              .where((r) => r.workerRef.id == worker.id)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (records.isEmpty) {
            return const Center(child: Text("لا يوجد سجلات"));
          }

          // Group by year-month
          final Map<String, List<DailyRecord>> grouped = {};
          for (final r in records) {
            final key = "${r.date.year}-${r.date.month.toString().padLeft(2,'0')}";
            grouped.putIfAbsent(key, () => []).add(r);
          }

          // Summary stats
          final totalAttendance = records.where((r) => !r.isAbsent).length;
          final totalAbsent = records.where((r) => r.isAbsent).length;
          final totalSalary = records.fold(0.0, (s, r) => s + (r.isAbsent ? 0 : r.totalSalary));
          final totalAdvance = records.fold(0.0, (s, r) => s + r.advance);

          return ListView(
            padding: EdgeInsets.all(12.w),
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat("حضور", "$totalAttendance", Colors.green),
                      _stat("غياب", "$totalAbsent", Colors.red),
                      _stat("الراتب الكلي", "${totalSalary.toInt()} ج", Colors.blue),
                      if (totalAdvance > 0) _stat("السلف", "${totalAdvance.toInt()} ج", Colors.orange),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Monthly breakdown
              ...grouped.entries.map((entry) {
                final monthRecords = entry.value;
                final monthSalary = monthRecords.fold(0.0, (s, r) => s + (r.isAbsent ? 0 : r.totalSalary));
                final monthAttend = monthRecords.where((r) => !r.isAbsent).length;
                final monthAbsent = monthRecords.where((r) => r.isAbsent).length;
                final monthAdvance = monthRecords.fold(0.0, (s, r) => s + r.advance);

                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ExpansionTile(
                    title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    subtitle: Text("حضور: $monthAttend | غياب: $monthAbsent | ${monthSalary.toInt()} ج"),
                    children: [
                      if (monthAdvance > 0)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          child: Row(children: [
                            Text("سلف: ${monthAdvance.toInt()} ج", style: TextStyle(color: Colors.orange.shade700)),
                          ]),
                        ),
                      ...monthRecords.map((r) => ListTile(
                        dense: true,
                        leading: Icon(
                          r.isAbsent ? Icons.cancel : Icons.check_circle,
                          color: r.isAbsent ? Colors.red : Colors.green,
                          size: 18.w,
                        ),
                        title: Text("${r.date.day}/${r.date.month}/${r.date.year}"),
                        trailing: r.isAbsent
                            ? Text("غائب", style: TextStyle(color: Colors.red))
                            : Text("${r.totalSalary.toInt()} ج", style: TextStyle(color: Colors.green)),
                      )),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13.sp)),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
      ],
    );
  }
}
