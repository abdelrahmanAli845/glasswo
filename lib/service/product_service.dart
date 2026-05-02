import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('products');

  Future<void> add(Product product) async {
    await _col.add(product.toMap());
  }

  Future<void> update(Product product) async {
    await _col.doc(product.id).update(product.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Product>> stream() {
    return _col.snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Product.fromDoc(e)).toList();
    });
  }
}