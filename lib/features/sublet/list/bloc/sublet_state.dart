part of 'sublet_bloc.dart';

class SubletState {
  final List<SubletModel>? subletList;
  final List<SubletModel>? filteredSubletList;
  final BlocState filterState;
  // Single category of sublet filtering
  final SingleSubletFilter? singleSubletFilter;
  final SubletFilter? subletFilter;

  const SubletState({
    this.subletList,
    this.filteredSubletList,
    this.filterState = const BlocState(),
    this.singleSubletFilter,
    this.subletFilter,
  });

  SubletState copyWith({
    List<SubletModel>? subletList,
    List<SubletModel>? filteredSubletList,
    BlocState? filterState,
    SingleSubletFilter? singleSubletFilter,
    SubletFilter? subletFilter,
  }) {
    return SubletState(
      subletList: subletList ?? this.subletList,
      filteredSubletList: filteredSubletList ?? this.filteredSubletList,
      filterState: filterState ?? this.filterState,
      singleSubletFilter: singleSubletFilter,
      subletFilter: subletFilter,
    );
  }
}
