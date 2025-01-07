part of 'sublet_bloc.dart';

class SubletState {
  final List<SubletModel>? subletList;
  final List<SubletModel>? filteredSubletList;
  final Exception? error;
  // Single category of sublet filtering
  final SingleSubletFilter? singleSubletFilter;
  final SubletFilter? subletFilter;

  const SubletState({
    this.subletList,
    this.filteredSubletList,
    this.error,
    this.singleSubletFilter,
    this.subletFilter,
  });

  SubletState copyWith({
    List<SubletModel>? subletList,
    List<SubletModel>? filteredSubletList,
    Exception? error,
    SingleSubletFilter? singleSubletFilter,
    SubletFilter? subletFilter,
  }) {
    return SubletState(
      subletList: subletList ?? this.subletList,
      filteredSubletList: filteredSubletList ?? this.filteredSubletList,
      error: error ?? this.error,
      singleSubletFilter: singleSubletFilter,
      subletFilter: subletFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubletState &&
        listEquals(other.subletList, subletList) &&
        other.error == error &&
        other.singleSubletFilter == singleSubletFilter &&
        listEquals(other.filteredSubletList, filteredSubletList) &&
        other.subletFilter == subletFilter;
  }

  @override
  int get hashCode => subletList.hashCode ^ error.hashCode;

  R when<R>({
    required R Function(List<SubletModel>? subletList, Exception? error) loaded,
    required R Function() initial,
  }) {
    if (subletList != null) {
      return loaded(subletList, error);
    } else {
      return initial();
    }
  }

  R maybeWhen<R>({
    R Function(List<SubletModel>? subletList, Exception? error)? loaded,
    R Function()? initial,
    required R Function() orElse,
  }) {
    if (subletList != null) {
      return loaded != null ? loaded(subletList, error) : orElse();
    } else {
      return initial != null ? initial() : orElse();
    }
  }

  @override
  String toString() {
    return 'SubletState(subletList: $subletList, error: $error)';
  }
}
