part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  
  const factory HomeState({
    required bool isLoading,
    required List<UserQuickProfile> profiles,
    Exception? error,

  }) = _HomeState;

  factory HomeState.initial() => const HomeState(
    isLoading: false,
    profiles: [],
  );
}