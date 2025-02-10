part of 'sublet_bloc.dart';

class SubletLoadingState extends BlocState {
  SubletLoadingState({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  SubletLoadingState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return SubletLoadingState(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  SubletLoadingState failure(AppException error) {
    return SubletLoadingState(
      isLoading: false,
      exception: error,
      isSuccess: false,
    );
  }

  @override
  SubletLoadingState loading() {
    return SubletLoadingState(
      isLoading: true,
      exception: null,
      isSuccess: false,
    );
  }

  @override
  SubletLoadingState resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  SubletLoadingState success() {
    return SubletLoadingState(
      isLoading: false,
      exception: null,
      isSuccess: true,
    );
  }
}

class SubletState {
  final List<SubletModel>? subletList;
  final List<SubletModel>? filteredSubletList;
  final SubletLoadingState? loading;
  // Single category of sublet filtering
  final SingleSubletFilter? singleSubletFilter;
  final SubletFilter? subletFilter;

  const SubletState({
    this.subletList,
    this.filteredSubletList,
    this.loading,
    this.singleSubletFilter,
    this.subletFilter,
  });

  SubletState copyWith({
    List<SubletModel>? subletList,
    List<SubletModel>? filteredSubletList,
    SubletLoadingState? loading,
    SingleSubletFilter? singleSubletFilter,
    SubletFilter? subletFilter,
  }) {
    return SubletState(
      subletList: subletList ?? this.subletList,
      filteredSubletList: filteredSubletList ?? this.filteredSubletList,
      loading: loading ?? this.loading,
      singleSubletFilter: singleSubletFilter,
      subletFilter: subletFilter,
    );
  }
}
