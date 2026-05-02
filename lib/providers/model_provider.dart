import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/product_model.dart';
import '../service/model_service.dart';

class ModelProvider extends ChangeNotifier {
  final ModelService service;

  ModelProvider(this.service);

  List<ProductModel> models = [];
  /// استماع لكل الموديلات
  void listenAll() {

    service.streamAll().listen((data) {
      models = data;
      notifyListeners();
    });
  }

  /// استماع حسب منتج
  void listen(DocumentReference productRef) {
    service.streamByProduct(productRef).listen((data) {
      models = data;
      notifyListeners();
    });
  }

  Future<void> save({
    String? id,
    required String name,
    required DocumentReference productRef,
  }) async {
    if (id == null) {
      await service.add(
        ProductModel(id: '', name: name, productRef: productRef),
      );
    } else {
      await service.update(
        ProductModel(id: id, name: name, productRef: productRef),
      );
    }
  }

  Future<void> delete(String id) async {
    await service.delete(id);
  }
}