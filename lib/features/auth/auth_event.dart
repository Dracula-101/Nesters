part of 'auth_bloc.dart';

@freezed
abstract class AuthEvent with _$AuthEvent {
  const factory AuthEvent() = _AuthEvent;
}

// Auth Google Sign in Event
class AuthGoogleSiginInEvent implements AuthEvent {}

// Auth Sign Out Event
class AuthSignOutEvent implements AuthEvent {}

// Auth User Changed Event
class AuthUserChangedEvent implements AuthEvent {
  final User? user;

  AuthUserChangedEvent(this.user);
}
