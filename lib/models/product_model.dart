import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String name;
  DocumentReference productRef;

  ProductModel({
    required this.id,
    required this.name,
    required this.productRef,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'productRef': productRef,
    };
  }

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'],
      productRef: data['productRef'],
    );
  }
}