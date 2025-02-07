part of 'apartment_form_cubit.dart';

class ApartmentFormState extends Equatable {
  final ApartmentModel? apartment;
  final bool? isPreFilled;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool isValidating;
  final bool? isSubmitting;
  final bool? isSubmitComplete;
  final Exception? submitError;
  final ApartmentImageUploadTask? imageUploadTask;
  final List<File> pickedImages;

  const ApartmentFormState({
    this.apartment,
    this.isPreFilled = false,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.isValidating = false,
    this.isSubmitting,
    this.isSubmitComplete,
    this.submitError,
    this.imageUploadTask,
    this.pickedImages = const [],
  });

  ApartmentFormState copyWith({
    ApartmentModel? apartment,
    bool? isPreFilled,
    Exception? error,
    int? pageNumber,
    bool? hasSecondPageAccess,
    bool? hasThirdPageAccess,
    bool? isValidating,
    bool? isSubmitting,
    bool? isSubmitComplete,
    Exception? submitError,
    ApartmentImageUploadTask? imageUploadTask,
    List<File>? pickedImages,
  }) {
    return ApartmentFormState(
      apartment: apartment ?? this.apartment,
      isPreFilled: isPreFilled ?? this.isPreFilled,
      error: error ?? this.error,
      pageNumber: pageNumber ?? this.pageNumber,
      hasSecondPageAccess: hasSecondPageAccess ?? this.hasSecondPageAccess,
      isValidating: isValidating ?? this.isValidating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitComplete: isSubmitComplete ?? this.isSubmitComplete,
      submitError: submitError ?? this.submitError,
      imageUploadTask: imageUploadTask ?? this.imageUploadTask,
      pickedImages: pickedImages ?? this.pickedImages,
    );
  }

  @override
  List<Object?> get props => [
        apartment,
        isPreFilled,
        error,
        pageNumber,
        hasSecondPageAccess,
        isValidating,
        isSubmitting,
        isSubmitComplete,
        submitError,
        imageUploadTask,
        pickedImages,
      ];
}
