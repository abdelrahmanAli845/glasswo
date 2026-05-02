import 'package:cloud_firestore/cloud_firestore.dart';

class WorkSession {
  DateTime checkIn;
  DateTime checkOut;

  WorkSession({
    required this.checkIn,
    required this.checkOut,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
    };
  }

  factory WorkSession.fromMap(Map<String, dynamic> data) {
    return WorkSession(
      checkIn: data['checkIn'].toDate(),
      checkOut: data['checkOut'].toDate(),
    );
  }
}