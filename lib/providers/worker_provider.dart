import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../models/worker.dart';
import '../service/worker_service.dart';

class WorkerProvider extends ChangeNotifier {
  final WorkerService service;

  WorkerProvider(this.service);

  List<Worker> workers = [];
  StreamSubscription? _sub;

  void listen() {
    if (_sub != null) return;
    _sub = service.stream().listen((data) {
      workers = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void save({
    String? id,
    required String name,
    required double salary,
    required double workHours,
    required bool hasBonus,
  }) {
    if (id == null) {
      service.add(
        Worker(
          id: '',
          name: name,
          dailySalary: salary,
          workHours: workHours,
          hasBonus: hasBonus, // 👈🔥 لازم يتحط
        ),
      );
    } else {
      service.update(
        Worker(
          id: id,
          name: name,
          dailySalary: salary,
          workHours: workHours,
          hasBonus: hasBonus, // 👈🔥 لازم يتحط
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    await service.delete(id);
  }
}