part of 'sublet_form_cubit.dart';

@freezed
class SubletFormState with _$SubletFormState {
  const factory SubletFormState({
    required SubletModel? sublet,
    Exception? error,
    @Default(0) int pageNumber,
    @Default(false) bool hasSecondPageAccess,
    @Default(false) bool hasThirdPageAccess,
    @Default(0) int validatingPage,
  }) = _SubletFormState;

  factory SubletFormState.initial() => const SubletFormState(
        sublet: null,
        pageNumber: 0,
      );
}
