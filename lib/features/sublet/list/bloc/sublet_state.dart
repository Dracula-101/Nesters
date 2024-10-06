part of 'sublet_bloc.dart';

// @freezed
// class SubletState with _$SubletState {
//   const factory SubletState({
//     List<SubletModel>? subletList,
//     Exception? error,
//   }) = _SubletState;

//   factory SubletState.initial() => SubletState(
//         subletList: [],
//         error: null,
//       );

//   factory SubletState.loaded(List<SubletModel> subletList) => SubletState(
//         subletList: subletList,
//         error: null,
//       );
// }

class SubletState {
  final List<SubletModel>? subletList;
  final Exception? error;

  const SubletState({
    this.subletList,
    this.error,
  });

  SubletState copyWith({
    List<SubletModel>? subletList,
    Exception? error,
  }) {
    return SubletState(
      subletList: subletList ?? this.subletList,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubletState &&
        listEquals(other.subletList, subletList) &&
        other.error == error;
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
