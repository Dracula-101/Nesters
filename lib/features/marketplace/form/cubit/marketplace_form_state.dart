part of 'marketplace_form_cubit.dart';

class MarketplaceFormState {
  final MarketplaceModel? item;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool isValidating;
  final bool? isSubmitting;
  final bool? isSubmitComplete;
  final Exception? submitError;
  final MarketplaceImageUploadTask? imageUploadTask;

  const MarketplaceFormState({
    this.item,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.isValidating = false,
    this.isSubmitting,
    this.isSubmitComplete,
    this.submitError,
    this.imageUploadTask,
  });

  MarketplaceFormState copyWith({
    MarketplaceModel? item,
    Exception? error,
    int? pageNumber,
    bool? hasSecondPageAccess,
    bool? isValidating,
    bool? isSubmitting,
    bool? isSubmitComplete,
    Exception? submitError,
    MarketplaceImageUploadTask? imageUploadTask,
  }) {
    return MarketplaceFormState(
      item: item ?? this.item,
      error: error ?? this.error,
      pageNumber: pageNumber ?? this.pageNumber,
      hasSecondPageAccess: hasSecondPageAccess ?? this.hasSecondPageAccess,
      isValidating: isValidating ?? this.isValidating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitComplete: isSubmitComplete ?? this.isSubmitComplete,
      submitError: submitError ?? this.submitError,
      imageUploadTask: imageUploadTask ?? this.imageUploadTask,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketplaceFormState &&
        other.item == item &&
        other.error == error &&
        other.pageNumber == pageNumber &&
        other.hasSecondPageAccess == hasSecondPageAccess &&
        other.isValidating == isValidating &&
        other.isSubmitting == isSubmitting &&
        other.isSubmitComplete == isSubmitComplete &&
        other.submitError == submitError &&
        other.imageUploadTask == imageUploadTask;
  }

  @override
  int get hashCode =>
      item.hashCode ^
      error.hashCode ^
      pageNumber.hashCode ^
      hasSecondPageAccess.hashCode ^
      isValidating.hashCode ^
      isSubmitting.hashCode ^
      isSubmitComplete.hashCode ^
      submitError.hashCode ^
      imageUploadTask.hashCode;
}
