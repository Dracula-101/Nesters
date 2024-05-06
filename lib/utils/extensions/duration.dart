part of 'extensions.dart';

extension DurationIntExtension on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get sec => Duration(seconds: this);
  Duration get min => Duration(minutes: this);
  Duration get hour => Duration(hours: this);
  Duration get day => Duration(days: this);
  Duration get week => Duration(days: this * 7);
  Duration get month => Duration(days: this * 30);
  Duration get year => Duration(days: this * 365);
}
