import 'package:cloud_firestore/cloud_firestore.dart';
import 'production_item.dart';

class DailyRecord {
  String id;
  DocumentReference workerRef;
  DateTime date;
  bool isAbsent;
  DateTime? checkIn;
  DateTime? checkOut;
  double totalSalary;
  bool onTime;
  int rating;
  String deductionType;
  String notes;
  double advance;

  List<ProductionItem> productions;

  DailyRecord({
    required this.id,
    required this.workerRef,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.onTime = false,
    this.rating = 0,
    this.isAbsent = false,
    this.deductionType = 'none',
    this.productions = const [],
    this.totalSalary = 0,
    this.notes = '',
    this.advance = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'workerRef': workerRef,
      'date': Timestamp.fromDate(date),
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'onTime': onTime,
      'rating': rating,
      'isAbsent': isAbsent,
      'deductionType': deductionType,
      'productions': productions.map((e) => e.toMap()).toList(),
      'totalSalary': totalSalary,
      'notes': notes,
      'advance': advance,
    };
  }

  factory DailyRecord.fromLocalJson(Map<String, dynamic> data) {
    return DailyRecord(
      id: data['id'] ?? '', // 👈 مهم جدًا
      workerRef: FirebaseFirestore.instance
          .collection('workers')
          .doc(data['workerId']),
      date: DateTime.parse(data['date']),
      checkIn:
      data['checkIn'] != null ? DateTime.parse(data['checkIn']) : null,
      checkOut:
      data['checkOut'] != null ? DateTime.parse(data['checkOut']) : null,
      onTime: data['onTime'] ?? false,
      rating: data['rating'] ?? 0,
      deductionType: data['deductionType'] ?? 'none',
      isAbsent: data['isAbsent'] ?? false,
      totalSalary: (data['totalSalary'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      advance: (data['advance'] ?? 0).toDouble(),
      productions: (data['productions'] as List? ?? [])
          .map((p) => ProductionItem(
        productRef: p['productId'] != null
            ? FirebaseFirestore.instance
            .collection('products')
            .doc(p['productId'])
            : null,
        modelRef: p['modelId'] != null
            ? FirebaseFirestore.instance
            .collection('models')
            .doc(p['modelId'])
            : null,
        shapeRef: p['shapeId'] != null
            ? FirebaseFirestore.instance
            .collection('shapes')
            .doc(p['shapeId'])
            : null,
        quantity: p['quantity'] ?? 0,
      ))
          .toList(),
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id, // 👈 مهم جدًا
      'workerId': workerRef.id,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'onTime': onTime,
      'rating': rating,
      'deductionType': deductionType,
      'totalSalary': totalSalary,
      'notes': notes,
      'advance': advance,
      'productions': productions.map((p) => {
        'productId': p.productRef?.id,
        'modelId': p.modelRef?.id,
        'shapeId': p.shapeRef?.id,
        'quantity': p.quantity,
      }).toList(),
    };
  }

  factory DailyRecord.fromMap(String id, Map<String, dynamic> data) {
    return DailyRecord(
      id: id,
      workerRef: data['workerRef'],
      date: (data['date'] as Timestamp).toDate(),
      checkIn: data['checkIn']?.toDate(),
      checkOut: data['checkOut']?.toDate(),
      onTime: data['onTime'] ?? false,
      rating: data['rating'] ?? 0,
      deductionType: data['deductionType'] ?? 'none',
      isAbsent: data['isAbsent'] ?? false,
      totalSalary: (data['totalSalary'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      advance: (data['advance'] ?? 0).toDouble(),
      productions: (data['productions'] as List? ?? [])
          .map((e) => ProductionItem.fromMap(e))
          .toList(),
    );
  }
}