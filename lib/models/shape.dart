import 'package:cloud_firestore/cloud_firestore.dart';

class Shape {
  String id;
  String name;
  int target;
  DocumentReference modelRef;

  Shape({
    required this.id,
    required this.name,
    required this.target,
    required this.modelRef,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dailyTarget': target,
      'modelRef': modelRef,
    };
  }

  factory Shape.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shape(
      id: doc.id,
      name: data['name'],
      target: data['dailyTarget'] ?? 0,
      modelRef: data['modelRef'] as DocumentReference<Object?>,
    );
  }
}