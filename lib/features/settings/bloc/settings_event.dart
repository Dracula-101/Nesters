part of 'settings_bloc.dart';

class SettingsEvent {
  const SettingsEvent();

  const factory SettingsEvent.loadProfile() = _LoadProfile;

  // when
  Future<void> when<R>({
    required void Function() loadProfile,
  }) async {
    if (this is _LoadProfile) {
      return loadProfile();
    } else {
      throw Exception('Event $this is not recognized');
    }
  }
}

class _LoadProfile extends SettingsEvent {
  const _LoadProfile();
}
