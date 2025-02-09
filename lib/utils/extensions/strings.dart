part of 'extensions.dart';

extension StringsExtension on String? {
  String get capitalize {
    if (this == null || (this?.isEmpty ?? false)) {
      return '';
    }
    return '${this![0].toUpperCase()}${this!.substring(1)}';
  }

  // Capitalize the first letter of every word in the string
  String get toTitleCase {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return this!
        .split(' ') // Split the string into words
        .map((word) => word.capitalize) // Capitalize each word
        .join(' '); // Join them back together with spaces
  }
}
