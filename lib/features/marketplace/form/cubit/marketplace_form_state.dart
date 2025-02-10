part of 'marketplace_form_cubit.dart';

class MarketplaceLoadingState extends BlocState {
  MarketplaceLoadingState({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  MarketplaceLoadingState failure(AppException error) {
    return MarketplaceLoadingState(
      isLoading: false,
      exception: error,
      isSuccess: false,
    );
  }

  @override
  MarketplaceLoadingState loading() {
    return MarketplaceLoadingState(
      isLoading: true,
      exception: null,
      isSuccess: false,
    );
  }

  @override
  MarketplaceLoadingState resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  MarketplaceLoadingState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return MarketplaceLoadingState(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  MarketplaceLoadingState success() {
    return MarketplaceLoadingState(
      isLoading: false,
      exception: null,
      isSuccess: true,
    );
  }
}

class MarketplaceFormState {
  final MarketplaceModel? item;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool isValidating;
  final MarketplaceLoadingState? submitState;
  final MarketplaceImageUploadTask? imageUploadTask;
  final List<MarketplaceCategoryModel> marketplaceCategories;
  final bool? isPreFilled;
  final List<File> selectedImages;

  const MarketplaceFormState({
    this.item,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.isValidating = false,
    this.submitState,
    this.imageUploadTask,
    this.marketplaceCategories = const [],
    this.isPreFilled,
    this.selectedImages = const [],
  });

  MarketplaceFormState copyWith({
    MarketplaceModel? item,
    Exception? error,
    int? pageNumber,
    bool? hasSecondPageAccess,
    bool? isValidating,
    MarketplaceLoadingState? submitState,
    Exception? submitError,
    MarketplaceImageUploadTask? imageUploadTask,
    List<MarketplaceCategoryModel>? marketplaceCategories,
    bool? isPreFilled,
    List<File>? selectedImages,
  }) {
    return MarketplaceFormState(
      item: item ?? this.item,
      error: error ?? this.error,
      pageNumber: pageNumber ?? this.pageNumber,
      hasSecondPageAccess: hasSecondPageAccess ?? this.hasSecondPageAccess,
      isValidating: isValidating ?? this.isValidating,
      submitState: submitState ?? submitState,
      imageUploadTask: imageUploadTask ?? this.imageUploadTask,
      marketplaceCategories:
          marketplaceCategories ?? this.marketplaceCategories,
      isPreFilled: isPreFilled ?? this.isPreFilled,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}
