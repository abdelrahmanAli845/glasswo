import 'package:cloud_firestore/cloud_firestore.dart';
import 'production_item.dart';
import 'work_session.dart';

class DailyRecord {
  String id;
  DocumentReference workerRef;
  DateTime date;
  bool isAbsent;
  List<WorkSession> sessions;
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
    this.sessions = const [],
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
      'sessions': sessions.map((s) => s.toMap()).toList(),
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

  factory DailyRecord.fromMap(String id, Map<String, dynamic> data) {
    List<WorkSession> sessions;
    if (data.containsKey('sessions') && data['sessions'] != null) {
      sessions = (data['sessions'] as List)
          .map((s) => WorkSession.fromMap(s as Map<String, dynamic>))
          .toList();
    } else {
      // backward compat: old records have top-level checkIn/checkOut
      sessions = [
        WorkSession(
          checkIn: (data['checkIn'] as Timestamp?)?.toDate(),
          checkOut: (data['checkOut'] as Timestamp?)?.toDate(),
        )
      ];
    }

    return DailyRecord(
      id: id,
      workerRef: data['workerRef'],
      date: (data['date'] as Timestamp).toDate(),
      sessions: sessions,
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

  factory DailyRecord.fromLocalJson(Map<String, dynamic> data) {
    List<WorkSession> sessions;
    if (data.containsKey('sessions') && data['sessions'] != null) {
      sessions = (data['sessions'] as List)
          .map((s) => WorkSession.fromLocalMap(s as Map<String, dynamic>))
          .toList();
    } else {
      sessions = [
        WorkSession(
          checkIn: data['checkIn'] != null ? DateTime.parse(data['checkIn']) : null,
          checkOut: data['checkOut'] != null ? DateTime.parse(data['checkOut']) : null,
        )
      ];
    }

    return DailyRecord(
      id: data['id'] ?? '',
      workerRef: FirebaseFirestore.instance
          .collection('workers')
          .doc(data['workerId']),
      date: DateTime.parse(data['date']),
      sessions: sessions,
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
      'id': id,
      'workerId': workerRef.id,
      'date': date.toIso8601String(),
      'sessions': sessions.map((s) => s.toLocalMap()).toList(),
      'onTime': onTime,
      'rating': rating,
      'deductionType': deductionType,
      'isAbsent': isAbsent,
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
}
