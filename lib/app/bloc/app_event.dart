part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent() = _AppEvent;

  const factory AppEvent.load() = _Load;
  const factory AppEvent.loaded(bool isSuccessful) = _Loaded;
}
