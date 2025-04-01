part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final UserInfo? user;
  final BlocState userVisibilityState;
  const SettingsState({
    this.user,
    this.userVisibilityState = const BlocState(isLoading: false),
  });

  @override
  List<Object?> get props => [user ?? '', userVisibilityState];

  SettingsState copyWith({
    UserInfo? user,
    BlocState? userVisibilityState,
  }) {
    return SettingsState(
      user: user ?? this.user,
      userVisibilityState: userVisibilityState ?? this.userVisibilityState,
    );
  }
}
