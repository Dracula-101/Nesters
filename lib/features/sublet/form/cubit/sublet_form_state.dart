part of 'sublet_form_cubit.dart';

@freezed
class SubletFormState with _$SubletFormState {
  const factory SubletFormState({
    required SubletModel? sublet,
    Exception? error,
    @Default(0) int pageNumber,
    @Default(false) bool hasSecondPageAccess,
    @Default(false) bool hasThirdPageAccess,
    @Default(false) bool isValidating,
    bool? isSubmitting,
    bool? isSubmitComplete,
    Exception? submitError,
    SubletImageUploadTask? imageUploadTask,
  }) = _SubletFormState;

  factory SubletFormState.initial() => const SubletFormState(
        sublet: null,
        pageNumber: 0,
      );
}
