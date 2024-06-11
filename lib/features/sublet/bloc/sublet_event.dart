part of 'sublet_bloc.dart';

@freezed
class SubletEvent with _$SubletEvent {
  const factory SubletEvent({
    bool? isLoading,
    List<SubletModel>? subletList,
    List<SubletModel>? subletListFiltered,
    String? searchQuery,
    Exception? error,
  }) = _SubletEvent;

  factory SubletEvent.loading() => SubletEvent(isLoading: true);

  factory SubletEvent.error(Exception error) => SubletEvent(error: error);
}
