part of 'marketplace_form_cubit.dart';

@freezed
class MarketplaceFormState with _$MarketplaceFormState {
  const factory MarketplaceFormState({
    required MarketplaceModel? item,
    Exception? error,
    @Default(0) int pageNumber,
    @Default(false) bool hasSecondPageAccess,
    @Default(false) bool isValidating,
    bool? isSubmitting,
    bool? isSubmitComplete,
    Exception? submitError,
    MarketplaceImageUploadTask? imageUploadTask,
  }) = _MarketplaceFormState;

  factory MarketplaceFormState.initial() => const MarketplaceFormState(
        item: null,
        pageNumber: 0,
      );
}
