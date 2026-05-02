import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ModelService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('models');

  Future<void> add(ProductModel model) async {
    await _col.add(model.toMap());
  }

  Future<void> update(ProductModel model) async {
    await _col.doc(model.id).update(model.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
  Stream<List<ProductModel>> streamAll() {
    return FirebaseFirestore.instance
        .collection('models')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromDoc(doc)).toList());
  }
  Stream<List<ProductModel>> streamByProduct(DocumentReference productRef) {
    return _col
        .where('productRef', isEqualTo: productRef)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((e) => ProductModel.fromDoc(e))
          .toList();
    });
  }
}