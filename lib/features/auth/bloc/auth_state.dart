part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();

  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.error(String message) = _Error;

  bool get isAuthenticated => this is _Authenticated;
  bool get isUnauthenticated => this is _Unauthenticated;

  User get user => (this as _Authenticated).user;

  //whenorNull
  R when<R>({
    R Function(User user)? authenticated,
    R Function()? unauthenticated,
    R Function()? initial,
    R Function()? loading,
    R Function(String message)? error,
  }) {
    if (this is _Authenticated) {
      return authenticated?.call((this as _Authenticated).user) ??
          (throw Exception('Authenticated state: $this'));
    } else if (this is _Unauthenticated) {
      return unauthenticated?.call() ??
          (throw Exception('Unauthenticated state: $this'));
    } else if (this is _Initial) {
      return initial?.call() ?? (throw Exception('Initial state: $this'));
    } else if (this is _Loading) {
      return loading?.call() ?? (throw Exception('Loading state: $this'));
    } else if (this is _Error) {
      return error?.call((this as _Error).message) ??
          (throw Exception('Error state: $this'));
    } else {
      throw Exception('Unknown state: $this');
    }
  }

  //when null
  R maybeWhen<R>({
    R Function(User user)? authenticated,
    R Function()? unauthenticated,
    R Function()? initial,
    R Function()? loading,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    if (this is _Authenticated) {
      return authenticated?.call((this as _Authenticated).user) ??
          orElse.call();
    } else if (this is _Unauthenticated) {
      return unauthenticated?.call() ?? orElse.call();
    } else if (this is _Initial) {
      return initial?.call() ?? orElse.call();
    } else if (this is _Loading) {
      return loading?.call() ?? orElse.call();
    } else if (this is _Error) {
      return error?.call((this as _Error).message) ?? orElse.call();
    } else {
      return orElse.call();
    }
  }

  // map
  R map<R>({
    required R Function(User) authenticated,
    required R Function() unauthenticated,
    required R Function() initial,
    required R Function() loading,
    required R Function(String) error,
  }) {
    if (this is _Authenticated) {
      return authenticated((this as _Authenticated).user);
    } else if (this is _Unauthenticated) {
      return unauthenticated();
    } else if (this is _Initial) {
      return initial();
    } else if (this is _Loading) {
      return loading();
    } else if (this is _Error) {
      return error((this as _Error).message);
    } else {
      throw Exception('Unknown state: $this');
    }
  }

  //maybeMap
  R? maybeMap<R>({
    required R Function(User) authenticated,
    required R Function() unauthenticated,
    required R Function() initial,
    required R Function() loading,
    required R Function(String) error,
    required R Function(AuthState) orElse,
  }) {
    if (this is _Authenticated) {
      return authenticated((this as _Authenticated).user);
    } else if (this is _Unauthenticated) {
      return unauthenticated();
    } else if (this is _Initial) {
      return initial();
    } else if (this is _Loading) {
      return loading();
    } else if (this is _Error) {
      return error((this as _Error).message);
    } else {
      return orElse(this);
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

class _Loading extends AuthState {
  const _Loading();
}

class _Error extends AuthState {
  final String message;

  const _Error(this.message);
}
