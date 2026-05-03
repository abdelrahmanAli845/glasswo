
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/worker.dart';
import '../../providers/worker_provider.dart';

void showWorkerForm(BuildContext context, {Worker? worker}) {
  final nameController =
  TextEditingController(text: worker?.name);

  final salaryController =
  TextEditingController(text: worker?.dailySalary.toString());

  final hoursController = TextEditingController(
    text: (worker?.workHours ?? 9.5).toString(),
  );

  bool hasBonus = worker?.hasBonus ?? true; // 👈 جديد

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  worker == null ? "إضافة عامل" : "تعديل عامل",
                  style: TextStyle(fontSize: 18.sp),
                ),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "اسم العامل"),
                ),

                TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "مرتب اليوم"),
                ),

                TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration:
                  InputDecoration(labelText: "عدد ساعات العمل"),
                ),

                /// 🔥 الحوافز
                SwitchListTile(
                  title: Text("يخضع لنظام الحوافز"),
                  value: hasBonus,
                  onChanged: (v) {
                    setState(() {
                      hasBonus = v;
                    });
                  },
                ),

                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final salary = double.tryParse(salaryController.text);
                    final hours = double.tryParse(hoursController.text);

                    if (name.isEmpty || salary == null || hours == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تأكد من ملء الاسم والمرتب وعدد الساعات"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final provider =
                        Provider.of<WorkerProvider>(context, listen: false);

                    try {
                      await provider.save(
                        id: worker?.id,
                        name: name,
                        salary: salary,
                        workHours: hours,
                        hasBonus: hasBonus,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("فشل الحفظ: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text("حفظ"),
                )
              ],
            ),
          );
        },
      );
    },
  );
}