part of 'marketplace_bloc.dart';

class MarketplaceState {
  final List<MarketplaceModel>? marketplaceList;
  final Exception? error;

  const MarketplaceState({
    this.marketplaceList,
    this.error,
  });

  MarketplaceState copyWith({
    List<MarketplaceModel>? marketplaceList,
    Exception? error,
  }) {
    return MarketplaceState(
      marketplaceList: marketplaceList ?? this.marketplaceList,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketplaceState &&
        listEquals(other.marketplaceList, marketplaceList) &&
        other.error == error;
  }

  @override
  int get hashCode => marketplaceList.hashCode ^ error.hashCode;
}
