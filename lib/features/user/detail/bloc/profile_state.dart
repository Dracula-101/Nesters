part of 'profile_bloc.dart';
class ProfileState {
  final UserProfile? userProfile;
  final BlocState profileStatus;

  const ProfileState({
    this.userProfile,
    this.profileStatus = const BlocState(),
  });

  ProfileState copyWith({
    UserProfile? userProfile,
    BlocState? profileStatus,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      profileStatus: profileStatus ?? this.profileStatus,
    );
  }
}
