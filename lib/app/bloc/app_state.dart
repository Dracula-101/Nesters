part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.initial() = _Initial;
  const factory AppState.loadInProgress() = _LoadInProgress;
  const factory AppState.loadSuccess() = _LoadSuccess;
  const factory AppState.loadFailure() = _LoadFailure;
}
