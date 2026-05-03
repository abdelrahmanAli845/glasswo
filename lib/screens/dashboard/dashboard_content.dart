import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
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
  String? _selectedWorkerId;

// ⏰ التأخير بعد 8:05 (الجلسة الأولى)
  bool isLate(DailyRecord r) {
    if (r.sessions.isEmpty) return false;
    final checkIn = r.sessions.first.checkIn;
    if (checkIn == null) return false;
    if (checkIn.hour > 8) return true;
    if (checkIn.hour == 8 && checkIn.minute > 5) return true;
    return false;
  }

// 📅 فلترة بالشهر
  List<DailyRecord> filterByMonth() {
    return widget.records.where((r) {
      return r.date.month == selectedMonth.month &&
          r.date.year == selectedMonth.year;
    }).toList();
  }

  void _exportCSV(List<Map<String, dynamic>> stats) {
    final monthStr = "${selectedMonth.month}/${selectedMonth.year}";
    final buffer = StringBuffer();
    buffer.writeln("تقرير شهر $monthStr");
    buffer.writeln("العامل,الحضور,الغياب,إجمالي الراتب,السلف,متوسط التقييم");
    for (final data in stats) {
      final w = data["worker"] as Worker;
      buffer.writeln(
        "${w.name},${data["attendance"]},${data["absent"]},${(data["salary"] as double).toInt()},${(data["advance"] as double).toInt()},${(data["avg"] as double).toStringAsFixed(1)}",
      );
    }
    Share.share(buffer.toString(), subject: "تقرير $monthStr");
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
        (sum, r) => sum + (r.isAbsent ? 0 : r.totalSalary),
      );
      final advance = workerRecords.fold(
        0.0,
            (sum, r) => sum + r.advance,
      );

      int attendance = workerRecords.where((r) => !r.isAbsent).length;
      int absent = workerRecords.where((r) => r.isAbsent).length;

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
        "absent": absent,
        "quality": fullRating,
        "late": lateDays,
        "onTime": onTimeDays,
        "avg": avgRating,
      };
    }).toList();

    // Apply worker filter
    final filteredStats = _selectedWorkerId == null
        ? workerStats
        : workerStats.where((d) => (d["worker"] as Worker).id == _selectedWorkerId).toList();

    // Compute totals from filtered stats
    for (final data in filteredStats) {
      totalFactory += data["salary"] as double;
      totalAdvance += data["advance"] as double;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard 🔥"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "تصدير CSV",
            onPressed: () => _exportCSV(filteredStats),
          ),
        ],
      ),
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

            // Worker filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: FilterChip(
                      label: const Text("الكل"),
                      selected: _selectedWorkerId == null,
                      onSelected: (_) => setState(() => _selectedWorkerId = null),
                    ),
                  ),
                  ...widget.workers.map((w) => Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: FilterChip(
                      label: Text(w.name),
                      selected: _selectedWorkerId == w.id,
                      onSelected: (_) => setState(() => _selectedWorkerId = w.id),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: 8.h),

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
                itemCount: filteredStats.length,
                itemBuilder: (context, index) {
                  final data = filteredStats[index];
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
                              if ((data["absent"] as int) > 0)
                                statColored("غياب", data["absent"], Colors.red.shade700),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text("$title: $value"),
    );
  }

  Widget statColored(String title, dynamic value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text("$title: $value", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
