abstract class AppException implements Exception {
  abstract String message;

  @override
  String toString() {
    return message;
  }
}
