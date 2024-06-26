part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.initial() = AppInitial;
  const factory AppState.loadInProgress() = AppLoadInProgress;
  const factory AppState.loadSuccess() = AppLoadSuccess;
  const factory AppState.loadFailure() = AppLoadFailure;
  const factory AppState.networkChange({
    required NetworkData data,
    required bool isOnline,
  }) = AppNetworkChange;
}
