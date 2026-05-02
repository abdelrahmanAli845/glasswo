import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionItem {
  DocumentReference? productRef;
  DocumentReference? modelRef;
  DocumentReference? shapeRef;
  int quantity;

  ProductionItem({
    required this.productRef,
    required this.modelRef,
    required this.shapeRef,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productRef': productRef,
      'modelRef': modelRef,
      'shapeRef': shapeRef,
      'quantity': quantity,
    };
  }

  factory ProductionItem.fromMap(Map<String, dynamic> map) {
    return ProductionItem(
      productRef: map['productRef'],
      modelRef: map['modelRef'],
      shapeRef: map['shapeRef'],
      quantity: map['quantity'] ?? 0,
    );
  }

  ProductionItem copyWith({
    DocumentReference? productRef,
    DocumentReference? modelRef,
    DocumentReference? shapeRef,
    int? quantity,
  }) {
    return ProductionItem(
      productRef: productRef ?? this.productRef,
      modelRef: modelRef ?? this.modelRef,
      shapeRef: shapeRef ?? this.shapeRef,
      quantity: quantity ?? this.quantity,
    );
  }
   factory ProductionItem.fromLocalMap(Map<String, dynamic> data) {
    return ProductionItem(
      productRef: data['productId'] != null
          ? FirebaseFirestore.instance
          .collection('products')
          .doc(data['productId'])
          : null,
      modelRef: data['modelId'] != null
          ? FirebaseFirestore.instance
          .collection('models')
          .doc(data['modelId'])
          : null,
      shapeRef: data['shapeId'] != null
          ? FirebaseFirestore.instance
          .collection('shapes')
          .doc(data['shapeId'])
          : null,
      quantity: data['quantity'] ?? 0,
    );
  }
  Map<String, dynamic> toLocalMap() {
    return {
      'productId': productRef?.id,
      'modelId': modelRef?.id,
      'shapeId': shapeRef?.id,
      'quantity': quantity,
    };
  }
}