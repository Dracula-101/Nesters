part of 'sublet_bloc.dart';

class SubletState {
  final List<SubletModel>? subletList;
  final List<SubletModel>? filteredSubletList;
  final BlocState loadingState;
  // Single category of sublet filtering
  final SingleSubletFilter? singleSubletFilter;
  final SubletFilter? subletFilter;

  const SubletState({
    this.subletList,
    this.filteredSubletList,
    this.loadingState = const BlocState(),
    this.singleSubletFilter,
    this.subletFilter,
  });

  SubletState copyWith({
    List<SubletModel>? subletList,
    List<SubletModel>? filteredSubletList,
    BlocState? loadingState,
    SingleSubletFilter? singleSubletFilter,
    SubletFilter? subletFilter,
  }) {
    return SubletState(
      subletList: subletList ?? this.subletList,
      filteredSubletList: filteredSubletList ?? this.filteredSubletList,
      loadingState: loadingState ?? this.loadingState,
      singleSubletFilter: singleSubletFilter,
      subletFilter: subletFilter,
    );
  }
}
