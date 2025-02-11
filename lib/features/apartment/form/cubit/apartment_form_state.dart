part of 'apartment_form_cubit.dart';

class ApartmentSubmitState extends BlocState {
  ApartmentSubmitState({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  ApartmentSubmitState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return ApartmentSubmitState(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  ApartmentSubmitState failure(AppException error) {
    return copyWith(
      isLoading: false,
      error: error,
      isSuccess: false,
    );
  }

  @override
  ApartmentSubmitState loading() {
    return copyWith(
      isLoading: true,
      error: null,
      isSuccess: false,
    );
  }

  @override
  ApartmentSubmitState resetLoading() {
    return copyWith(
      isLoading: false,
      error: null,
      isSuccess: false,
    );
  }

  @override
  ApartmentSubmitState success() {
    return copyWith(
      isLoading: false,
      error: null,
      isSuccess: true,
    );
  }
}

class ApartmentFormState extends Equatable {
  final ApartmentModel? apartment;
  final bool? isPreFilled;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool isValidating;
  final ApartmentSubmitState? submitState;
  final ApartmentImageUploadTask? imageUploadTask;
  final List<File> pickedImages;

  const ApartmentFormState({
    this.apartment,
    this.isPreFilled = false,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.isValidating = false,
    this.submitState,
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
    ApartmentSubmitState? submitState,
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
      submitState: submitState ?? this.submitState,
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
        submitState,
        imageUploadTask,
        pickedImages,
      ];
}
