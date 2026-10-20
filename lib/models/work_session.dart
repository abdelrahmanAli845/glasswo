import 'package:cloud_firestore/cloud_firestore.dart';

class WorkSession {
  DateTime? checkIn;
  DateTime? checkOut;

  WorkSession({this.checkIn, this.checkOut});

  Map<String, dynamic> toMap() => {
        'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
        'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      };

  factory WorkSession.fromMap(Map<String, dynamic> data) => WorkSession(
        checkIn: (data['checkIn'] as Timestamp?)?.toDate(),
        checkOut: (data['checkOut'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toLocalMap() => {
        'checkIn': checkIn?.toIso8601String(),
        'checkOut': checkOut?.toIso8601String(),
      };

  factory WorkSession.fromLocalMap(Map<String, dynamic> data) => WorkSession(
        checkIn: data['checkIn'] != null ? DateTime.parse(data['checkIn']) : null,
        checkOut: data['checkOut'] != null ? DateTime.parse(data['checkOut']) : null,
      );
}