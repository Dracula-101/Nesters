part of 'extensions.dart';

extension TimestampExtension on Timestamp {
  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
