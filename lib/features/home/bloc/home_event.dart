part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.initial() = _Initial;
  const factory HomeEvent.loading() = _Loading;
  const factory HomeEvent.loaded(
    PagingController<int, UserQuickProfile> pagingController,
  ) = _Loaded;
  const factory HomeEvent.fetchNextPage(List<UserQuickProfile> newProfiles) = _FetchNextPage;
}