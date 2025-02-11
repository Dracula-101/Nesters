part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final UserInfo? user;

  const SettingsState({this.user});

  @override
  List<Object?> get props => [user];

  SettingsState copyWith({UserInfo? user}) {
    return SettingsState(
      user: user ?? this.user,
    );
  }
}
