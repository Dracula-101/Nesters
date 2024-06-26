part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent() = _AppEvent;

  const factory AppEvent.load() = _Load;
  const factory AppEvent.loaded({
    required bool isSuccessful,
    required bool isOnboaringComplete,
  }) = _Loaded;

  const factory AppEvent.networkChange({
    required NetworkData data,
    required bool isOnline,
  }) = _NetworkChange;
}
