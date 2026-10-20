
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/worker.dart';
import '../../providers/worker_provider.dart';

void showWorkerForm(BuildContext context, {Worker? worker}) {
  // نمسك الـ provider والـ scaffoldMessenger قبل فتح الـ modal
  final provider = Provider.of<WorkerProvider>(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);

  final nameController = TextEditingController(text: worker?.name ?? '');
  final salaryController = TextEditingController(
    text: worker != null ? worker.dailySalary.toString() : '',
  );
  final hoursController = TextEditingController(
    text: (worker?.workHours ?? 9.5).toString(),
  );

  bool hasBonus = worker?.hasBonus ?? true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (sheetContext, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Text(
                    worker == null ? "إضافة عامل" : "تعديل عامل",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "اسم العامل"),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: salaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "مرتب اليوم"),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "عدد ساعات العمل"),
                  ),
                ),

                SwitchListTile(
                  title: const Text("يخضع لنظام الحوافز"),
                  value: hasBonus,
                  onChanged: (v) => setState(() => hasBonus = v),
                ),

                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 44.h)),
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final salary = double.tryParse(salaryController.text);
                      final hours = double.tryParse(hoursController.text);

                      if (name.isEmpty || salary == null || hours == null) {
                        messenger.showSnackBar(const SnackBar(
                          content: Text("تأكد من ملء الاسم والمرتب وعدد الساعات"),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }

                      try {
                        await provider.save(
                          id: worker?.id,
                          name: name,
                          salary: salary,
                          workHours: hours,
                          hasBonus: hasBonus,
                        );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      } catch (e) {
                        messenger.showSnackBar(SnackBar(
                          content: Text("فشل الحفظ: $e"),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                    child: const Text("حفظ"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}