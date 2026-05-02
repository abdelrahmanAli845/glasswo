import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/shape_provider.dart';
import 'shape_form.dart';

class ShapesScreen extends StatefulWidget {
  final ProductModel model;

  const ShapesScreen({
    super.key,
    required this.model,
  });

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {

  @override
  void initState() {
    super.initState();

    final modelRef = FirebaseFirestore.instance
        .collection('models')
        .doc(widget.model.id);

    Future.microtask(() {
      Provider.of<ShapeProvider>(context, listen: false)
          .listen(modelRef);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShapeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.name),
      ),

      body: provider.shapes.isEmpty
          ? Center(child: Text("مفيش أشكال لسه"))
          : ListView.builder(
        itemCount: provider.shapes.length,
        itemBuilder: (_, i) {
          final shape = provider.shapes[i];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: ListTile(
              title: Text(shape.name),
              subtitle: Text("الهدف: ${shape.target}"),

              onTap: () {
                final modelRef = FirebaseFirestore.instance
                    .collection('models')
                    .doc(widget.model.id);

                showShapeForm(
                  context,
                  modelId: modelRef,
                  shape: shape,
                );
              },

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✏️ تعديل
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      final modelRef = FirebaseFirestore.instance
                          .collection('models')
                          .doc(widget.model.id);

                      showShapeForm(
                        context,
                        modelId: modelRef,
                        shape: shape, // 🔥 ده المهم
                      );
                    },
                  ),

                  // 🗑️ حذف
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.delete(shape.id);
                    },
                  ),
                ],
              ),            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final modelRef = FirebaseFirestore.instance
              .collection('models')
              .doc(widget.model.id);

          showShapeForm(
            context,
            modelId: modelRef,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}