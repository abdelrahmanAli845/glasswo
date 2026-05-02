import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/model_provider.dart';

void showModelForm(
    BuildContext context, {
      required DocumentReference productId,
      ProductModel? model,
    }) {
  final controller =
  TextEditingController(text: model?.name);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
                  model == null ? "إضافة موديل" : "تعديل موديل",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 12.h),

                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "اسم الموديل",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 16.h),

                ElevatedButton(
                  onPressed: () {
                    Provider.of<ModelProvider>(context, listen: false)
                        .save(
                      id: model?.id,
                      name: controller.text,
                      productRef: productId,
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