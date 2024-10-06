part of 'settings_bloc.dart';

abstract class SettingsEvent {
  const factory SettingsEvent.started() = _Started;
}

class _Started implements SettingsEvent {
  const _Started();
}
