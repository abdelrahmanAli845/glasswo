import 'package:flutter/cupertino.dart';

import '../models/product.dart';
import '../service/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService service;

  ProductProvider(this.service);

  List<Product> products = [];
  void listen() {

    service.stream().listen((data) {
      products = data;
      notifyListeners();
    });
  }

  Future<void> save({String? id, required String name}) async {
    if (id == null) {
      await service.add(Product(id: '', name: name));
    } else {
      await service.update(Product(id: id, name: name));
    }
  }

  Future<void> delete(String id) async {
    await service.delete(id);
  }
}