class GoogleSignInFailedException implements Exception {
  final String localizedMessage;
  GoogleSignInFailedException(
      [this.localizedMessage = 'An unknown error occurred.']);

  @override
  String toString() {
    return localizedMessage;
  }

  factory GoogleSignInFailedException.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return GoogleSignInFailedException(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return GoogleSignInFailedException(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return GoogleSignInFailedException(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return GoogleSignInFailedException(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return GoogleSignInFailedException(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return GoogleSignInFailedException(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return GoogleSignInFailedException(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return GoogleSignInFailedException(
          'The credential verification ID received is invalid.',
        );
      default:
        return GoogleSignInFailedException();
    }
  }
}

class AuthSignInError implements Exception {
  final String message;
  AuthSignInError(this.message);

  @override
  String toString() {
    return message;
  }
}

class AppleSignInFailedException implements Exception {
  final String localizedMessage;
  AppleSignInFailedException(
      [this.localizedMessage = 'An unknown error occurred.']);

  @override
  String toString() {
    return localizedMessage;
  }
}
