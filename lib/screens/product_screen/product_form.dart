import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';

void showProductForm(BuildContext context, {Product? product}) {
  final controller =
  TextEditingController(text: product?.name);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 🔥 مهم
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product == null ? "إضافة منتج" : "تعديل منتج"),

              TextField(controller: controller),

              ElevatedButton(
                onPressed: () {
                  Provider.of<ProductProvider>(context, listen: false)
                      .save(
                    id: product?.id,
                    name: controller.text,
                  );

                  Navigator.pop(context);
                },
                child: Text("حفظ"),
              )
            ],
          ),
        ),
      );
    },
  );
}