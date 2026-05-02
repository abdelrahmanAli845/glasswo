import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/model_provider.dart';
import '../shapeScreen/shape_screen.dart';
import 'model_form.dart';

class ModelsScreen extends StatefulWidget {
  final Product product;

  const ModelsScreen({super.key, required this.product});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {

  @override
  void initState() {
    super.initState();

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);

    Future.microtask(() {
      Provider.of<ModelProvider>(context, listen: false)
          .listen(productRef);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ModelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("موديلات ${widget.product.name}"),
      ),

      body: provider.models.isEmpty
          ? Center(child: Text("مفيش موديلات"))
          : ListView.builder(
        itemCount: provider.models.length,
        cacheExtent: 500,

        itemBuilder: (_, i) {
          final model = provider.models[i];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: ListTile(
              title: Text(model.name),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShapesScreen(model: model),
                  ),
                );
              },

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✏️ تعديل
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final productRef = FirebaseFirestore.instance
                          .collection('products')
                          .doc(widget.product.id);

                      showModelForm(
                        context,
                        productId: productRef,
                        model: model, // 🔥 ده المهم
                      );
                    },
                  ),

                  // 🗑️ حذف
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.delete(model.id);
                    },
                  ),
                ],
              ),            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final productRef = FirebaseFirestore.instance
              .collection('products')
              .doc(widget.product.id);

          showModelForm(
            context,
            productId: productRef, // 🔥 مهم
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}