part of 'marketplace_bloc.dart';

@freezed
class MarketplaceState with _$MarketplaceState {
  const factory MarketplaceState({
    List<MarketplaceModel>? marketplaceList,
    Exception? error,
  }) = _MarketplaceState;

  factory MarketplaceState.initial() => MarketplaceState(
        marketplaceList: [],
        error: null,
      );

  factory MarketplaceState.loaded(List<MarketplaceModel> marketplaceList) =>
      MarketplaceState(
        marketplaceList: marketplaceList,
        error: null,
      );
}
