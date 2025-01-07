part of 'marketplace_bloc.dart';

class MarketplaceState {
  final List<MarketplaceModel>? marketplaceList;
  final List<MarketplaceModel>? marketplaceListFiltered;
  final Exception? error;
  final MarketplaceSingleFilter? singleFilter;

  const MarketplaceState({
    this.marketplaceList,
    this.marketplaceListFiltered,
    this.error,
    this.singleFilter,
  });

  MarketplaceState copyWith({
    List<MarketplaceModel>? marketplaceList,
    List<MarketplaceModel>? marketplaceListFiltered,
    Exception? error,
    MarketplaceSingleFilter? filter,
  }) {
    return MarketplaceState(
      marketplaceList: marketplaceList ?? this.marketplaceList,
      marketplaceListFiltered:
          marketplaceListFiltered ?? this.marketplaceListFiltered,
      error: error ?? this.error,
      singleFilter: filter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketplaceState &&
        listEquals(other.marketplaceList, marketplaceList) &&
        listEquals(other.marketplaceListFiltered, marketplaceListFiltered) &&
        other.error == error &&
        other.singleFilter == singleFilter;
  }

  @override
  int get hashCode => marketplaceList.hashCode ^ error.hashCode;
}
