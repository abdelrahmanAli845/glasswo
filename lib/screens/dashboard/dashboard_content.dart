import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/daily_record.dart';
import '../../models/worker.dart';

class DashboardContent extends StatefulWidget {
  final List<Worker> workers;
  final List<DailyRecord> records;

  const DashboardContent({
    super.key,
    required this.workers,
    required this.records,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {

  DateTime selectedMonth = DateTime.now();

// ⏰ التأخير بعد 8:5
  bool isLate(DailyRecord r) {
    if (r.checkIn == null) return false;

    final time = r.checkIn!;

    if (time.hour > 8) return true;
    if (time.hour == 8 && time.minute > 5) return true;

    return false;
  }

// 📅 فلترة بالشهر
  List<DailyRecord> filterByMonth() {
    return widget.records.where((r) {
      return r.date.month == selectedMonth.month &&
          r.date.year == selectedMonth.year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final filteredRecords = filterByMonth();

    double totalFactory = 0;
    double totalAdvance = 0;

    final workerStats = widget.workers.map((worker) {

      final workerRecords = filteredRecords.where((r) {
        return r.workerRef.id == worker.id;
      }).toList();

      final salary = workerRecords.fold(
        0.0,
            (sum, r) => sum + r.totalSalary,
      );
      final advance = workerRecords.fold(
        0.0,
            (sum, r) => sum + r.advance,
      );
      totalFactory += salary;
      totalAdvance += advance;

      int attendance = workerRecords.length;

      int fullRating =
          workerRecords.where((r) => r.rating == 5).length;
      int lateDays =
          workerRecords.where((r) => isLate(r)).length;

      int onTimeDays = attendance - lateDays;

      double avgRating = 0;
      if (workerRecords.isNotEmpty) {
        avgRating = workerRecords
            .map((e) => e.rating)
            .reduce((a, b) => a + b) /
            workerRecords.length;
      }

      return {
        "worker": worker,
        "salary": salary,
        "advance": advance,
        "attendance": attendance,
        "quality": fullRating,
        "late": lateDays,
        "onTime": onTimeDays,
        "avg": avgRating,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard 🔥")),
      body: Padding(
        padding:  EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                          selectedMonth.year, selectedMonth.month - 1);
                    });
                  },
                ),
                Text(
                  "${selectedMonth.month}/${selectedMonth.year}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                          selectedMonth.year, selectedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 10.h),

            /// 💰 إجمالي المصنع
            Card(
              child: ListTile(
                title: const Text("إجمالي المرتبات"),
                trailing: Text(
                  "${totalFactory.toInt()} ج",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (totalAdvance > 0)
              Card(
                child: ListTile(
                  title: const Text("إجمالي السلف"),
                  trailing: Text(
                    "${totalAdvance.toInt()} ج",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 10.h),

            /// 👷 قائمة العمال
            Expanded(
              child: ListView.builder(
                itemCount: workerStats.length,
                itemBuilder: (context, index) {
                  final data = workerStats[index];
                  final worker = data["worker"] as Worker;

                  final salary = data["salary"] as double;
                  final advance = data["advance"] as double;
                  final avg = data["avg"] as double;

                  return Card(
                    margin:
                    EdgeInsets.symmetric(vertical: 6.h),
                    child: Padding(
                      padding:  EdgeInsets.all(10.w),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          /// 👷 + 💰
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(worker.name,
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold)),
                              Text("${salary.toInt()} ج",
                                  style: const TextStyle(
                                      color: Colors.green)),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          /// 📊 Stats
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              stat("حضور", data["attendance"]),
                              stat("جودة", data["quality"]),
                              stat("⭐️", avg.toStringAsFixed(1)),
                              stat("متأخر", data["late"]),
                              stat("ملتزم", data["onTime"]),
                              if (advance > 0)
                                stat("سلف", "${advance.toInt()} ج"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget stat(String title, dynamic value) {
    return Container(
      padding:
      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text("$title: $value"),
    );
  }
}