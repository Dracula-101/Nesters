part of 'sublet_bloc.dart';

@freezed
class SubletState with _$SubletState {
  const factory SubletState({
    bool? isLoading,
    List<SubletModel>? subletList,
    List<SubletModel>? subletListFiltered,
    String? searchQuery,
    Exception? error,
  }) = _SubletState;

  factory SubletState.initial() => const SubletState(
        isLoading: true,
        subletList: [],
        subletListFiltered: [],
        searchQuery: '',
        error: null,
      );

  factory SubletState.loading() => const SubletState(
        isLoading: true,
        subletList: [],
        subletListFiltered: [],
        searchQuery: '',
        error: null,
      );

  factory SubletState.error(Exception error) => SubletState(
        isLoading: false,
        subletList: [],
        subletListFiltered: [],
        searchQuery: '',
        error: error,
      );
}
