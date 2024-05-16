part of 'profile_bloc.dart';

@freezed
class ProfileState with _$ProfileState {
  
  const factory ProfileState({
    required bool isLoading,
    required UserProfile? userProfile,
    Exception? error,
  }) = _ProfileState;

  factory ProfileState.inital() => const ProfileState(
        isLoading: false,
        userProfile: null,
      );

}
