part of 'apartment_form_cubit.dart';

class ApartmentFormState extends Equatable {
  final ApartmentModel? apartment;
  final bool? isPreFilled;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool isValidating;
  final BlocState submitState;
  final ApartmentImageUploadTask? imageUploadTask;
  final List<File> pickedImages;

  const ApartmentFormState({
    this.apartment,
    this.isPreFilled = false,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.isValidating = false,
    this.submitState =  const BlocState(isLoading: false),
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
    BlocState? submitState,
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
