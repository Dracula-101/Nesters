part of 'user_bloc.dart';

@freezed
class UserState with _$UserState {
  factory UserState({
    required User user,
    @Default([]) List<University?> universities,
    @Default(false) bool isLoadingUniversities,
    @Default([]) List<Degree?> degrees,
    @Default(false) bool isLoadingDegrees,
  }) = _UserState;

  factory UserState.initial() {
    return UserState(
      user: User.empty(),
      universities: [],
      degrees: [],
    );
  }
}
