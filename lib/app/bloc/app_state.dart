part of 'app_bloc.dart';

// @freezed
// class AppState with _$AppState {
//   const factory AppState.initial() = AppInitial;
//   const factory AppState.loadInProgress() = AppLoadInProgress;
//   const factory AppState.loadSuccess() = AppLoadSuccess;
//   const factory AppState.loadFailure() = AppLoadFailure;
//   const factory AppState.networkChange({
//     required NetworkData data,
//     required bool isOnline,
//   }) = AppNetworkChange;
// }

class AppState {
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

  AppState({
    this.isLoading = true,
    this.isOnline = true,
    this.networkData = NetworkData.UNKNOWN,
    this.error,
    this.universities = const [],
    this.degrees = const [],
    this.marketplaceCategory = const [],
    this.universitiesState = BlocState(),
    this.degreesState = BlocState(),
    this.marketplaceCategoryState = BlocState(),
  });

  AppState copyWith({
    bool? isLoading,
    bool? isOnline,
    NetworkData? networkData,
    Exception? error,
    List<University?>? universities,
    List<Degree?>? degrees,
    List<MarketplaceCategoryModel>? marketplaceCategory,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      networkData: networkData ?? this.networkData,
      error: error ?? this.error,
      universities: universities ?? this.universities,
      isLoadingUniversities:
          isLoadingUniversities ?? this.isLoadingUniversities,
      degrees: degrees ?? this.degrees,
      isLoadingDegrees: isLoadingDegrees ?? this.isLoadingDegrees,
      marketplaceCategory: marketplaceCategory ?? this.marketplaceCategory,
      isLoadingMarketplaceCategory:
          isLoadingMarketplaceCategory ?? this.isLoadingMarketplaceCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppState &&
        other.isLoading == isLoading &&
        other.isOnline == isOnline &&
        other.networkData == networkData &&
        other.error == error;
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isOnline.hashCode ^
      networkData.hashCode ^
      error.hashCode;
}
