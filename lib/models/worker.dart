import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  final String id;
  final String name;
  final double dailySalary;
  final double workHours;
  final bool hasBonus; // 👈 هل عليه نظام حوافز ولا ثابت

  Worker({
    required this.id,
    required this.name,
    required this.dailySalary,
    required this.workHours,
    this.hasBonus = true, // 👈 default = فيه حوافز
  });

  /// 🔥 من Firestore
  factory Worker.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Worker(
      id: doc.id,
      name: data['name'] ?? '',
      dailySalary: (data['dailySalary'] ?? 0).toDouble(),
      workHours: (data['workHours'] ?? 9.5).toDouble(),
      hasBonus: data['hasBonus'] ?? true, // 👈 الجديد
    );
  }

  /// 🔥 للتحويل لـ Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dailySalary': dailySalary,
      'workHours': workHours,
      'hasBonus': hasBonus, // 👈 الجديد
    };
  }
}