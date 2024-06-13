part of 'sublet_bloc.dart';

@freezed
class SubletState with _$SubletState {
  const factory SubletState({
    List<SubletModel>? subletList,
    Exception? error,
  }) = _SubletState;

  factory SubletState.initial() => SubletState(
        subletList: [],
        error: null,
      );

  factory SubletState.loaded(List<SubletModel> subletList) => SubletState(
        subletList: subletList,
        error: null,
      );
}
