part of 'profile_bloc.dart';

class ProfileStatus extends BlocState {
  ProfileStatus({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  ProfileStatus copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return ProfileStatus(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  ProfileStatus failure(AppException error) {
    return ProfileStatus(
      isLoading: false,
      exception: error,
      isSuccess: false,
    );
  }

  @override
  ProfileStatus loading() {
    return ProfileStatus(
      isLoading: true,
      exception: null,
      isSuccess: false,
    );
  }

  @override
  ProfileStatus resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  ProfileStatus success() {
    return ProfileStatus(
      isLoading: false,
      exception: null,
      isSuccess: true,
    );
  }
}

class ProfileState {
  final UserProfile? userProfile;
  final ProfileStatus? profileStatus;

  const ProfileState({
    this.userProfile,
    this.profileStatus,
  });

  ProfileState copyWith({
    UserProfile? userProfile,
    ProfileStatus? profileStatus,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      profileStatus: profileStatus ?? this.profileStatus,
    );
  }
}
