part of 'marketplace_search_cubit.dart';

class MarketplaceSearchState extends Equatable {
  const MarketplaceSearchState(
      {this.searchResults = const [],
      this.searchQuery = '',
      this.state = const BlocState(isLoading: false)});

  final List<SearchedMarketplaceModel> searchResults;
  final String searchQuery;
  final BlocState state;

  @override
  List<Object> get props => [searchResults, searchQuery, state];

  factory MarketplaceSearchState.loading() {
    return const MarketplaceSearchState(
      searchResults: [],
      searchQuery: '',
      state: const BlocState(isLoading: true),
    );
  }

  factory MarketplaceSearchState.loaded(
      {required List<SearchedMarketplaceModel> searchResults,
      required String searchQuery}) {
    return MarketplaceSearchState(
      searchResults: searchResults,
      searchQuery: searchQuery,
      state: const BlocState(isLoading: false),
    );
  }

  factory MarketplaceSearchState.error({required AppException error}) {
    return MarketplaceSearchState(
      searchResults: [],
      searchQuery: '',
      state: BlocState(isLoading: false, exception: error),
    );
  }

  MarketplaceSearchState copyWith(
      {List<SearchedMarketplaceModel>? searchResults,
      String? searchQuery,
      BlocState? state}) {
    return MarketplaceSearchState(
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      state: state ?? this.state,
    );
  }
}
