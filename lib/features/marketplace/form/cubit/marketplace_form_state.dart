part of 'marketplace_form_cubit.dart';

class MarketplaceLoadingState extends BlocState {}

class MarketplaceFormState {
  final MarketplaceModel? item;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool isValidating;
  final BlocState submitState;
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
    this.submitState = const BlocState(isLoading: false),
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
    BlocState? submitState,
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
      submitState: submitState ?? this.submitState,
      imageUploadTask: imageUploadTask ?? this.imageUploadTask,
      marketplaceCategories:
          marketplaceCategories ?? this.marketplaceCategories,
      isPreFilled: isPreFilled ?? this.isPreFilled,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}
