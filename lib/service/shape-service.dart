import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shape.dart';

class ShapeService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('shapes');

  Future<void> add(Shape shape) async {
    await _col.add(shape.toMap());
  }

  Future<void> update(Shape shape) async {
    await _col.doc(shape.id).update(shape.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
  Stream<List<Shape>> streamAll() {
    return FirebaseFirestore.instance
        .collection('shapes')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Shape.fromDoc(doc)).toList());
  }
  Stream<List<Shape>> streamByModel(DocumentReference modelRef) {
    return _col
        .where('modelRef', isEqualTo: modelRef)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((e) => Shape.fromDoc(e)).toList();
    });
  }
}