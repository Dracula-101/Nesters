part of 'sublet_form_cubit.dart';

class SubletFormState {
  final SubletModel? sublet;
  final Exception? error;
  final int pageNumber;
  final bool hasSecondPageAccess;
  final bool hasThirdPageAccess;
  final bool isValidating;
  final bool? isSubmitting;
  final bool? isSubmitComplete;
  final Exception? submitError;
  final SubletImageUploadTask? imageUploadTask;

  const SubletFormState({
    this.sublet,
    this.error,
    this.pageNumber = 0,
    this.hasSecondPageAccess = false,
    this.hasThirdPageAccess = false,
    this.isValidating = false,
    this.isSubmitting,
    this.isSubmitComplete,
    this.submitError,
    this.imageUploadTask,
  });

  SubletFormState copyWith({
    SubletModel? sublet,
    Exception? error,
    int? pageNumber,
    bool? hasSecondPageAccess,
    bool? hasThirdPageAccess,
    bool? isValidating,
    bool? isSubmitting,
    bool? isSubmitComplete,
    Exception? submitError,
    SubletImageUploadTask? imageUploadTask,
  }) {
    return SubletFormState(
      sublet: sublet ?? this.sublet,
      error: error ?? this.error,
      pageNumber: pageNumber ?? this.pageNumber,
      hasSecondPageAccess: hasSecondPageAccess ?? this.hasSecondPageAccess,
      hasThirdPageAccess: hasThirdPageAccess ?? this.hasThirdPageAccess,
      isValidating: isValidating ?? this.isValidating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitComplete: isSubmitComplete ?? this.isSubmitComplete,
      submitError: submitError ?? this.submitError,
      imageUploadTask: imageUploadTask ?? this.imageUploadTask,
    );
  }
}
