// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class AuthException implements AppException {
  @override
  String get message;
  AuthErrorCode get authErrorCode;
}

enum AuthErrorCode {
  // google related error code
  GOOGLE_SIGN_IN_FAILED,
  GOOGLE_NO_USER_FOUND,
  GOOGLE_USER_ID_TOKEN_FAILED,
  GOOGLE_USER_TOKEN_FAILED,

  // apple related error code
  APPLE_SIGN_IN_FAILED,

  SIGN_OUT_FAILED;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class GoogleSignInFailedException implements AuthException {
  GoogleSignInFailedException({
    required this.message,
    required this.authErrorCode,
  });

  @override
  AuthErrorCode authErrorCode;

  @override
  String message;
}

class AppleSignInFailedException implements AuthException {
  AppleSignInFailedException({
    required this.message,
    required this.authErrorCode,
  });

  @override
  AuthErrorCode authErrorCode;

  @override
  String message;
}

class SignInOutFailedException implements AuthException {
  SignInOutFailedException({
    required this.message,
  });

  @override
  AuthErrorCode authErrorCode = AuthErrorCode.SIGN_OUT_FAILED;

  @override
  String message;
}
