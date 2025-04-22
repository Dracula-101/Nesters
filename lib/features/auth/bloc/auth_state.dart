part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();

  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.googleSignInLoading() = _GoogleSignInLoading;
  const factory AuthState.appleSignInLoading() = _AppleSignInLoading;
  const factory AuthState.deleteAccountLoading() = _DeleteAccountLoading;
  const factory AuthState.error(AppException error) = _AuthError;
  const factory AuthState.logInSuccess({
    required bool fromGoogleSignIn,
    required bool fromAppleSignIn,
  }) = _LogInSuccess;

  bool get isAuthenticated => this is _Authenticated;
  bool get isUnauthenticated => this is _Unauthenticated;

  User get user => (this as _Authenticated).user;

  bool hasError() {
    return this is _AuthError;
  }

  AppException get error => (this as _AuthError).error;

  //whenorNull
  R when<R>({
    required R Function(User user)? authenticated,
    required R Function()? unauthenticated,
    required R Function()? initial,
    required R Function()? googleSignInLoading,
    required R Function()? appleSignInLoading,
    required R Function()? deleteAccountLoading,
    required R Function(AppException error)? error,
    required R Function(bool fromGoogleSignIn, bool fromAppleSignIn)?
        logInSuccess,
  }) {
    if (this is _Authenticated) {
      return authenticated?.call((this as _Authenticated).user) ??
          (throw Exception('Authenticated state: $this'));
    } else if (this is _Unauthenticated) {
      return unauthenticated?.call() ??
          (throw Exception('Unauthenticated state: $this'));
    } else if (this is _Initial) {
      return initial?.call() ?? (throw Exception('Initial state: $this'));
    } else if (this is _GoogleSignInLoading) {
      return googleSignInLoading?.call() ??
          (throw Exception('Loading state: $this'));
    } else if (this is _AppleSignInLoading) {
      return appleSignInLoading?.call() ??
          (throw Exception('Loading state: $this'));
    } else if (this is _DeleteAccountLoading) {
      return deleteAccountLoading?.call() ??
          (throw Exception('Loading state: $this'));
    } else if (this is _AuthError) {
      return error?.call((this as _AuthError).error) ??
          (throw Exception('Error state: $this'));
    } else if (this is _LogInSuccess) {
      return logInSuccess?.call((this as _LogInSuccess).fromGoogleSignIn,
              (this as _LogInSuccess).fromAppleSignIn) ??
          (throw Exception('LogInSuccess state: $this'));
    } else {
      throw Exception('Unknown state: $this');
    }
  }

  //when null
  R maybeWhen<R>({
    R Function(User user)? authenticated,
    R Function()? unauthenticated,
    R Function()? initial,
    R Function()? googleSignInLoading,
    R Function()? appleSignInLoading,
    R Function()? deleteAccountLoading,
    R Function(AppException error)? error,
    R Function(bool fromGoogleSignIn, bool fromAppleSignIn)? logInSuccess,
    required R Function() orElse,
  }) {
    if (this is _Authenticated) {
      return authenticated?.call((this as _Authenticated).user) ??
          orElse.call();
    } else if (this is _Unauthenticated) {
      return unauthenticated?.call() ?? orElse.call();
    } else if (this is _Initial) {
      return initial?.call() ?? orElse.call();
    } else if (this is _GoogleSignInLoading) {
      return googleSignInLoading?.call() ?? orElse.call();
    } else if (this is _AppleSignInLoading) {
      return appleSignInLoading?.call() ?? orElse.call();
    } else if (this is _DeleteAccountLoading) {
      return deleteAccountLoading?.call() ?? orElse.call();
    } else if (this is _AuthError) {
      return error?.call((this as _AuthError).error) ?? orElse.call();
    } else if (this is _LogInSuccess) {
      return logInSuccess?.call((this as _LogInSuccess).fromGoogleSignIn,
              (this as _LogInSuccess).fromAppleSignIn) ??
          orElse.call();
    } else {
      return orElse.call();
    }
  }

  // map
  R map<R>({
    required R Function(User) authenticated,
    required R Function() unauthenticated,
    required R Function() initial,
    required R Function() googleSignInLoading,
    required R Function() appleSignInLoading,
    required R Function() deleteAccountLoading,
    required R Function(AppException) error,
    required R Function(bool fromGoogleSignIn, bool fromAppleSignIn)
        logInSuccess,
  }) {
    if (this is _Authenticated) {
      return authenticated((this as _Authenticated).user);
    } else if (this is _Unauthenticated) {
      return unauthenticated();
    } else if (this is _Initial) {
      return initial();
    } else if (this is _GoogleSignInLoading) {
      return googleSignInLoading();
    } else if (this is _AppleSignInLoading) {
      return appleSignInLoading();
    } else if (this is _DeleteAccountLoading) {
      return deleteAccountLoading();
    } else if (this is _AuthError) {
      return error((this as _AuthError).error);
    } else if (this is _LogInSuccess) {
      return logInSuccess((this as _LogInSuccess).fromGoogleSignIn,
          (this as _LogInSuccess).fromAppleSignIn);
    } else {
      throw Exception('Unknown state: $this');
    }
  }

  //maybeMap
  R? maybeMap<R>({
    R Function(User)? authenticated,
    R Function()? unauthenticated,
    R Function()? initial,
    R Function()? googleSignInLoading,
    R Function()? appleSignInLoading,
    R Function()? deleteAccountLoading,
    R Function(AppException)? error,
    R Function(AuthState)? orElse,
    R Function(bool fromGoogleSignIn, bool fromAppleSignIn)? logInSuccess,
  }) {
    if (this is _Authenticated) {
      return authenticated?.call((this as _Authenticated).user) ??
          orElse?.call(this);
    } else if (this is _Unauthenticated) {
      return unauthenticated?.call() ?? orElse?.call(this);
    } else if (this is _Initial) {
      return initial?.call() ?? orElse?.call(this);
    } else if (this is _GoogleSignInLoading) {
      return googleSignInLoading?.call() ?? orElse?.call(this);
    } else if (this is _AppleSignInLoading) {
      return appleSignInLoading?.call() ?? orElse?.call(this);
    } else if (this is _DeleteAccountLoading) {
      return deleteAccountLoading?.call() ?? orElse?.call(this);
    } else if (this is _AuthError) {
      return error?.call((this as _AuthError).error) ?? orElse?.call(this);
    } else if (this is _LogInSuccess) {
      return logInSuccess?.call((this as _LogInSuccess).fromGoogleSignIn,
              (this as _LogInSuccess).fromAppleSignIn) ??
          orElse?.call(this);
    } else {
      return orElse?.call(this);
    }
  }
}

class _Initial extends AuthState {
  const _Initial();
}

class _Authenticated extends AuthState {
  @override
  final User user;

  const _Authenticated(this.user);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _GoogleSignInLoading extends AuthState {
  const _GoogleSignInLoading();
}

class _AppleSignInLoading extends AuthState {
  const _AppleSignInLoading();
}

class _DeleteAccountLoading extends AuthState {
  const _DeleteAccountLoading();
}

class _AuthError extends AuthState {
  final AppException error;

  const _AuthError(this.error);
}

class _LogInSuccess extends AuthState {
  final bool fromGoogleSignIn;
  final bool fromAppleSignIn;
  const _LogInSuccess({
    required this.fromGoogleSignIn,
    required this.fromAppleSignIn,
  });
}
