import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/worker.dart';

class WorkerService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('workers');

  Future<void> add(Worker worker) async {
    await _col.add(worker.toMap());
  }

  Future<void> update(Worker worker) async {
    await _col.doc(worker.id).update(worker.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Worker>> stream() {
    return _col.snapshots().map((snapshot) {
      return snapshot.docs.map((e) => Worker.fromDoc(e)).toList();
    });
  }}