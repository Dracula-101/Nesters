part of 'user_bloc.dart';

@freezed
class UserEvent with _$UserEvent {

  const factory UserEvent.loadUser({
    required User user,
  }) = _LoadUser;
  const factory UserEvent.loadUniversities() = _LoadUniversities;
  const factory UserEvent.loadDegrees() = _LoadDegrees;
}
