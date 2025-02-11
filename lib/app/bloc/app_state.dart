part of 'app_bloc.dart';

class AppState extends Equatable {
  final bool isLoading;
  final bool isOnline;
  final NetworkData networkData;
  final Exception? error;

  final List<University?> universities;
  final List<Degree?> degrees;
  final List<MarketplaceCategoryModel> marketplaceCategory;
  final BlocState universitiesState;
  final BlocState degreesState;
  final BlocState marketplaceCategoryState;

  const AppState({
    this.isLoading = true,
    this.isOnline = true,
    this.networkData = NetworkData.UNKNOWN,
    this.error,
    this.universities = const [],
    this.degrees = const [],
    this.marketplaceCategory = const [],
    this.universitiesState = const BlocState(),
    this.degreesState = const BlocState(),
    this.marketplaceCategoryState = const BlocState(),
  });

  AppState copyWith({
    bool? isLoading,
    bool? isOnline,
    NetworkData? networkData,
    Exception? error,
    List<University?>? universities,
    List<Degree?>? degrees,
    List<MarketplaceCategoryModel>? marketplaceCategory,
    BlocState? universitiesState,
    BlocState? degreesState,
    BlocState? marketplaceCategoryState,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      networkData: networkData ?? this.networkData,
      error: error ?? this.error,
      universities: universities ?? this.universities,
      degrees: degrees ?? this.degrees,
      marketplaceCategory: marketplaceCategory ?? this.marketplaceCategory,
      universitiesState: universitiesState ?? this.universitiesState,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isOnline,
        networkData,
        error,
        universities,
        degrees,
        marketplaceCategory,
        universitiesState,
        degreesState,
        marketplaceCategoryState,
      ];
}
