
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
                  onPressed: () {
                    final provider =
                    Provider.of<WorkerProvider>(context, listen: false);

                    provider.save(
                      id: worker?.id,
                      name: nameController.text,
                      salary: double.parse(salaryController.text),
                      workHours:
                      double.parse(hoursController.text),
                      hasBonus: hasBonus, // 👈 مهم
                    );

                    Navigator.pop(context);
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