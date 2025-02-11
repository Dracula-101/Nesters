part of 'settings_bloc.dart';

class SettingsEvent {
  const SettingsEvent();

  const factory SettingsEvent.loadProfile() = _LoadProfile;

  const factory SettingsEvent.changeVisibility({required bool isVisible}) =
      _ChangeVisibility;

  // when
  Future<void> when<R>({
    required void Function() loadProfile,
    required Future<void> Function(bool) changeVisibility,
  }) async {
    if (this is _LoadProfile) {
      return loadProfile();
    } else if (this is _ChangeVisibility) {
      return changeVisibility((this as _ChangeVisibility).isVisible);
    } else {
      throw Exception('Event $this is not recognized');
    }
  }
}

class _LoadProfile extends SettingsEvent {
  const _LoadProfile();
}

class _ChangeVisibility extends SettingsEvent {
  final bool isVisible;
  const _ChangeVisibility({required this.isVisible});
}
