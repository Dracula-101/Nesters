part of 'marketplace_bloc.dart';

class MarketplaceState {
  final List<MarketplaceModel>? marketplaceList;
  final List<MarketplaceModel>? marketplaceListFiltered;
  final Exception? error;
  final MarketplaceSingleFilter? singleFilter;
  final MarketplaceAdvancedFilter? advancedFilter;

  const MarketplaceState({
    this.marketplaceList,
    this.marketplaceListFiltered,
    this.error,
    this.singleFilter,
    this.advancedFilter,
  });

  MarketplaceState copyWith({
    List<MarketplaceModel>? marketplaceList,
    List<MarketplaceModel>? marketplaceListFiltered,
    Exception? error,
    MarketplaceSingleFilter? filter,
    MarketplaceAdvancedFilter? advancedFilter,
  }) {
    return MarketplaceState(
      marketplaceList: marketplaceList ?? this.marketplaceList,
      marketplaceListFiltered:
          marketplaceListFiltered ?? this.marketplaceListFiltered,
      error: error ?? this.error,
      singleFilter: filter,
      advancedFilter: advancedFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketplaceState &&
        listEquals(other.marketplaceList, marketplaceList) &&
        listEquals(other.marketplaceListFiltered, marketplaceListFiltered) &&
        other.error == error &&
        other.singleFilter == singleFilter &&
        other.advancedFilter == advancedFilter;
  }

  @override
  int get hashCode => marketplaceList.hashCode ^ error.hashCode;
}

enum MarketplaceFilterTypes {
  price,
  category;

  @override
  String toString() {
    return this == MarketplaceFilterTypes.price ? 'Price' : 'Category';
  }
}
