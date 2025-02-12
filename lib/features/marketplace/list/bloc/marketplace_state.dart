part of 'marketplace_bloc.dart';

class MarketplaceState extends Equatable {
  final List<MarketplaceModel>? marketplaceList;
  final List<MarketplaceModel>? marketplaceListFiltered;
  final BlocState filterState;
  final MarketplaceSingleFilter? singleFilter;
  final MarketplaceAdvancedFilter? advancedFilter;

  const MarketplaceState({
    this.marketplaceList,
    this.marketplaceListFiltered,
    this.filterState = const BlocState(isLoading: false),
    this.singleFilter,
    this.advancedFilter,
  });

  MarketplaceState copyWith({
    List<MarketplaceModel>? marketplaceList,
    List<MarketplaceModel>? marketplaceListFiltered,
    BlocState? filterState,
    MarketplaceSingleFilter? filter,
    MarketplaceAdvancedFilter? advancedFilter,
  }) {
    return MarketplaceState(
      marketplaceList: marketplaceList ?? this.marketplaceList,
      marketplaceListFiltered:
          marketplaceListFiltered ?? this.marketplaceListFiltered,
      filterState: filterState ?? this.filterState,
      singleFilter: filter,
      advancedFilter: advancedFilter,
    );
  }

  @override
  List<Object?> get props => [
        marketplaceList,
        marketplaceListFiltered,
        filterState,
        singleFilter,
        advancedFilter,
      ];
}

enum MarketplaceFilterTypes {
  price,
  category;

  @override
  String toString() {
    return this == MarketplaceFilterTypes.price ? 'Price' : 'Category';
  }
}
