import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/shape.dart';
import '../service/shape-service.dart';

class ShapeProvider extends ChangeNotifier {
  final ShapeService service;

  ShapeProvider(this.service);

  List<Shape> shapes = [];
  /// استماع لكل الأشكال حسب الموديل
  void listen(DocumentReference modelRef) {

    service.streamByModel(modelRef).listen((data) {
      shapes = data;
      notifyListeners();
    });
  }

  /// استماع لكل الأشكال مرة واحدة
  void listenAll() {
    service.streamAll().listen((data) {
      shapes = data;
      notifyListeners();
    });
  }

  Future<void> save({
    String? id,
    required String name,
    required int target,
    required DocumentReference modelRef,
  }) async {
    if (id == null) {
      await service.add(
        Shape(id: '', name: name, target: target, modelRef: modelRef),
      );
    } else {
      await service.update(
        Shape(id: id, name: name, target: target, modelRef: modelRef),
      );
    }
  }

  Future<void> delete(String id) async {
    await service.delete(id);
  }
}