part of 'user_filter_bloc.dart';

@freezed
class UserFilterEvent with _$UserFilterEvent {
  const factory UserFilterEvent.started() = _Started;
}