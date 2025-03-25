part of 'marketplace_search_cubit.dart';

class MarketplaceSearchState extends Equatable {
  const MarketplaceSearchState({
    required this.searchResults,
    required this.recentSearches,
    required this.searchQuery,
    required this.searchState,
  });

  final List<SearchedMarketplaceModel> searchResults;
  final List<String> recentSearches;
  final String searchQuery;
  final BlocState searchState;

  @override
  List<Object> get props =>
      [searchResults, recentSearches, searchQuery, searchState];

  factory MarketplaceSearchState.initial() {
    return const MarketplaceSearchState(
      searchResults: [],
      searchQuery: '',
      recentSearches: [],
      searchState: BlocState(isLoading: false),
    );
  }

  MarketplaceSearchState copyWith({
    List<SearchedMarketplaceModel>? searchResults,
    List<String>? recentSearches,
    String? searchQuery,
    BlocState? searchState,
  }) {
    return MarketplaceSearchState(
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      searchState: searchState ?? this.searchState,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}
