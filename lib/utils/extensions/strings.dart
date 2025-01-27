part of 'extensions.dart';

extension StringsExtension on String? {
  String get capitalize {
    if (this == null || (this?.isEmpty ?? false)) {
      return '';
    }
    return '${this![0].toUpperCase()}${this!.substring(1)}';
  }
}
