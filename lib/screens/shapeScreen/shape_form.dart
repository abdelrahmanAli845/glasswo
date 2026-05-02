import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/shape.dart';
import '../../providers/shape_provider.dart';

void showShapeForm(
    BuildContext context, {
      required DocumentReference modelId, // 🔥 بدل productId
      Shape? shape,
    }) {
  final nameController =
  TextEditingController(text: shape?.name);

  final targetController =
  TextEditingController(text: shape?.target.toString() ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 🔥 يحل مشكلة الكيبورد
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shape == null ? "إضافة شكل" : "تعديل شكل",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12.h),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "اسم الشكل",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12.h),

                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "الهدف اليومي",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 16.h),

                ElevatedButton(
                  onPressed: () {
                    Provider.of<ShapeProvider>(context, listen: false)
                        .save(
                      id: shape?.id,
                      name: nameController.text,
                      target: int.tryParse(targetController.text) ?? 0,
                      modelRef: modelId, // 🔥 الصح
                    );

                    Navigator.pop(context);
                  },
                  child: Text("حفظ"),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}