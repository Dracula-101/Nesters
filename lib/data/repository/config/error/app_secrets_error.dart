class AppSecretsError implements Exception {
  final String message;

  AppSecretsError(this.message);

  @override
  String toString() {
    return message;
  }

  factory AppSecretsError.initalizeError() {
    return AppSecretsError('AppSecrets not initialized');
  }
}
