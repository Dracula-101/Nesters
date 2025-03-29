part of 'app_bloc.dart';

class AppState extends Equatable {
  final bool isLoading;
  final AppThemeMode themeMode;
  final bool isOnline;
  final NetworkData networkData;
  final Exception? error;

  final List<University> universities;
  final List<Degree> degrees;
  final List<MarketplaceCategoryModel> marketplaceCategory;
  final List<Language> languages;
  final BlocState universitiesState;
  final BlocState degreesState;
  final BlocState marketplaceCategoryState;
  final BlocState languageState;

  const AppState({
    this.isLoading = true,
    this.isOnline = true,
    this.themeMode = AppThemeMode.light,
    this.networkData = NetworkData.UNKNOWN,
    this.error,
    this.universities = const [],
    this.degrees = const [],
    this.marketplaceCategory = const [],
    this.languages = const [],
    this.universitiesState = const BlocState(),
    this.degreesState = const BlocState(),
    this.marketplaceCategoryState = const BlocState(),
    this.languageState = const BlocState(),
  });

  AppState copyWith({
    bool? isLoading,
    bool? isOnline,
    AppThemeMode? themeMode,
    NetworkData? networkData,
    Exception? error,
    List<University>? universities,
    List<Degree>? degrees,
    List<MarketplaceCategoryModel>? marketplaceCategory,
    List<Language>? languages,
    BlocState? universitiesState,
    BlocState? degreesState,
    BlocState? marketplaceCategoryState,
    BlocState? languageState,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      themeMode: themeMode ?? this.themeMode,
      networkData: networkData ?? this.networkData,
      error: error ?? this.error,
      universities: universities ?? this.universities,
      degrees: degrees ?? this.degrees,
      marketplaceCategory: marketplaceCategory ?? this.marketplaceCategory,
      languages: languages ?? this.languages,
      universitiesState: universitiesState ?? this.universitiesState,
      degreesState: degreesState ?? this.degreesState,
      marketplaceCategoryState:
          marketplaceCategoryState ?? this.marketplaceCategoryState,
      languageState: languageState ?? this.languageState,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isOnline,
        themeMode,
        networkData,
        error,
        universities,
        degrees,
        marketplaceCategory,
        languages,
        universitiesState,
        degreesState,
        marketplaceCategoryState,
        languageState,
      ];
}
