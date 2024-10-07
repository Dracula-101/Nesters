part of 'profile_bloc.dart';

class ProfileState {
  final bool isLoading;
  final UserProfile? userProfile;
  final Exception? error;

  const ProfileState({
    this.isLoading = true,
    this.userProfile,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? userProfile,
    Exception? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileState &&
        other.userProfile == userProfile &&
        other.error == error &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode =>
      userProfile.hashCode ^ error.hashCode ^ isLoading.hashCode;
}
