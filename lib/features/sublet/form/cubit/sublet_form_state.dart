part of 'sublet_form_cubit.dart';

class SubletSubmitState extends BlocState {
  SubletSubmitState({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  SubletSubmitState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return SubletSubmitState(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  SubletSubmitState failure(AppException error) {
    return copyWith(
      isLoading: false,
      error: error,
      isSuccess: false,
    );
  }

  @override
  SubletSubmitState loading() {
    return copyWith(
      isLoading: true,
      error: null,
      isSuccess: false,
    );
  }

  @override
  SubletSubmitState resetLoading() {
    return copyWith(
      isLoading: false,
      error: null,
      isSuccess: false,
    );
  }

  @override
  SubletSubmitState success() {
    return copyWith(
      isLoading: false,
      error: null,
      isSuccess: true,
    );
  }
}

class SubletFormState extends Equatable {
  final SubletModel? sublet;
  final bool? isPreFilled;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool hasThirdPageAccess;
  final bool isValidating;
  final SubletSubmitState? submitState;
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
    this.submitState,
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
    SubletSubmitState? submitState,
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
