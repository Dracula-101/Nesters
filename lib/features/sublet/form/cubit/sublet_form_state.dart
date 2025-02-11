part of 'sublet_form_cubit.dart';

class SubletFormState extends Equatable {
  final SubletModel? sublet;
  final bool? isPreFilled;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool hasThirdPageAccess;
  final bool isValidating;
  final BlocState submitState;
  final SubletImageUploadTask? imageUploadTask;
  final List<File> pickedImages;

  const SubletFormState({
    this.sublet,
    this.isPreFilled = false,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.hasThirdPageAccess = false,
    this.isValidating = false,
    this.submitState = const BlocState(isLoading: false),
    this.imageUploadTask,
    this.pickedImages = const [],
  });

  SubletFormState copyWith({
    SubletModel? sublet,
    bool? isPreFilled,
    Exception? error,
    int? pageNumber,
    bool? hasSecondPageAccess,
    bool? hasThirdPageAccess,
    bool? isValidating,
    BlocState? submitState,
    SubletImageUploadTask? imageUploadTask,
    List<File>? pickedImages,
  }) {
    return SubletFormState(
      sublet: sublet ?? this.sublet,
      isPreFilled: isPreFilled ?? this.isPreFilled,
      error: error ?? this.error,
      pageNumber: pageNumber ?? this.pageNumber,
      hasSecondPageAccess: hasSecondPageAccess ?? this.hasSecondPageAccess,
      hasThirdPageAccess: hasThirdPageAccess ?? this.hasThirdPageAccess,
      isValidating: isValidating ?? this.isValidating,
      submitState: submitState ?? this.submitState,
      imageUploadTask: imageUploadTask ?? this.imageUploadTask,
      pickedImages: pickedImages ?? this.pickedImages,
    );
  }

  @override
  List<Object?> get props => [
        sublet,
        isPreFilled,
        error,
        pageNumber,
        hasSecondPageAccess,
        hasThirdPageAccess,
        isValidating,
        submitState,
        imageUploadTask,
        pickedImages,
      ];
}
