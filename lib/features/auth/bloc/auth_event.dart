part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();

  const factory AuthEvent.googleSignIn() = _AuthGoogleSiginInEvent;
  const factory AuthEvent.appleSignIn() = _AuthAppleSiginInEvent;
  const factory AuthEvent.authSignOut() = _AuthSignOutEvent;
  const factory AuthEvent.authUserChanged(User? user) = _AuthUserChangedEvent;
  const factory AuthEvent.deleteAccount() = _DeleteAccountEvent;

  R when<R>({
    required R Function() authGoogleSignIn,
    required R Function() authAppleSignIn,
    required R Function() authSignOut,
    required R Function(User? user) authUserChanged,
    required R Function() deleteAccount,
  }) {
    if (this is _AuthGoogleSiginInEvent) {
      return authGoogleSignIn();
    } else if (this is _AuthAppleSiginInEvent) {
      return authAppleSignIn();
    } else if (this is _AuthSignOutEvent) {
      return authSignOut();
    } else if (this is _AuthUserChangedEvent) {
      return authUserChanged((this as _AuthUserChangedEvent).user);
    } else if (this is _DeleteAccountEvent) {
      return deleteAccount();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeWhen<R>({
    R Function()? authGoogleSignIn,
    R Function()? authAppleSignIn,
    R Function()? authSignOut,
    R Function(User? user)? authUserChanged,
    R Function()? deleteAccount,
    required R Function() orElse,
  }) {
    if (this is _AuthGoogleSiginInEvent) {
      return authGoogleSignIn != null ? authGoogleSignIn() : orElse();
    } else if (this is _AuthAppleSiginInEvent) {
      return authAppleSignIn != null ? authAppleSignIn() : orElse();
    } else if (this is _AuthSignOutEvent) {
      return authSignOut != null ? authSignOut() : orElse();
    } else if (this is _AuthUserChangedEvent) {
      return authUserChanged != null
          ? authUserChanged((this as _AuthUserChangedEvent).user)
          : orElse();
    } else if (this is _DeleteAccountEvent) {
      return deleteAccount != null ? deleteAccount() : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R map<R>({
    required R Function() authGoogleSignIn,
    required R Function() authAppleSignIn,
    required R Function() authSignOut,
    required R Function(User? user) authUserChanged,
    required R Function() deleteAccount,
  }) {
    if (this is _AuthGoogleSiginInEvent) {
      return authGoogleSignIn();
    } else if (this is _AuthAppleSiginInEvent) {
      return authAppleSignIn();
    } else if (this is _AuthSignOutEvent) {
      return authSignOut();
    } else if (this is _AuthUserChangedEvent) {
      return authUserChanged((this as _AuthUserChangedEvent).user);
    } else if (this is _DeleteAccountEvent) {
      return deleteAccount();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeMap<R>({
    R Function()? authGoogleSignIn,
    R Function()? authAppleSignIn,
    R Function()? authSignOut,
    R Function(User? user)? authUserChanged,
    R Function()? deleteAccount,
    required R Function() orElse,
  }) {
    if (this is _AuthGoogleSiginInEvent) {
      return authGoogleSignIn != null ? authGoogleSignIn() : orElse();
    } else if (this is _AuthAppleSiginInEvent) {
      return authAppleSignIn != null ? authAppleSignIn() : orElse();
    } else if (this is _AuthSignOutEvent) {
      return authSignOut != null ? authSignOut() : orElse();
    } else if (this is _AuthUserChangedEvent) {
      return authUserChanged != null
          ? authUserChanged((this as _AuthUserChangedEvent).user)
          : orElse();
    } else if (this is _DeleteAccountEvent) {
      return deleteAccount != null ? deleteAccount() : orElse();
    } else {
      throw Exception('Unknown event: $this');
    }
  }
}

class _AuthGoogleSiginInEvent extends AuthEvent {
  const _AuthGoogleSiginInEvent();
}

class _AuthAppleSiginInEvent extends AuthEvent {
  const _AuthAppleSiginInEvent();
}

class _AuthSignOutEvent extends AuthEvent {
  const _AuthSignOutEvent();
}

class _AuthUserChangedEvent extends AuthEvent {
  final User? user;
  const _AuthUserChangedEvent(this.user);
}

class _DeleteAccountEvent extends AuthEvent {
  const _DeleteAccountEvent();
}
