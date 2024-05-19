import 'package:cloud_firestore/cloud_firestore.dart';

extension TimestampExtension on Timestamp {
  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
