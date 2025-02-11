part of 'apartment_bloc.dart';

class ApartmentLoadingState extends BlocState {
  ApartmentLoadingState({
    required bool isLoading,
    required AppException? exception,
    required bool isSuccess,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          isSuccess: isSuccess,
        );

  @override
  ApartmentLoadingState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return ApartmentLoadingState(
      isLoading: isLoading ?? this.isLoading,
      exception: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  ApartmentLoadingState failure(AppException error) {
    return ApartmentLoadingState(
      isLoading: false,
      exception: error,
      isSuccess: false,
    );
  }

  @override
  ApartmentLoadingState loading() {
    return ApartmentLoadingState(
      isLoading: true,
      exception: null,
      isSuccess: false,
    );
  }

  @override
  ApartmentLoadingState resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  ApartmentLoadingState success() {
    return ApartmentLoadingState(
      isLoading: false,
      exception: null,
      isSuccess: true,
    );
  }
}

class ApartmentState {
  final List<ApartmentModel>? apartmentList;
  final List<ApartmentModel>? filteredApartmentList;
  final ApartmentLoadingState? loadingState;
  // Single category of apartment filtering
  final SingleApartmentFilter? singleApartmentFilter;
  final ApartmentFilter? apartmentFilter;

  const ApartmentState({
    this.apartmentList,
    this.filteredApartmentList,
    this.singleApartmentFilter,
    this.loadingState,
    this.apartmentFilter,
  });

  ApartmentState copyWith({
    List<ApartmentModel>? apartmentList,
    List<ApartmentModel>? filteredApartmentList,
    ApartmentLoadingState? loadingState,
    SingleApartmentFilter? singleApartmentFilter,
    ApartmentFilter? apartmentFilter,
  }) {
    return ApartmentState(
      apartmentList: apartmentList ?? this.apartmentList,
      filteredApartmentList:
          filteredApartmentList ?? this.filteredApartmentList,
      loadingState: loadingState ?? this.loadingState,
      singleApartmentFilter: singleApartmentFilter,
      apartmentFilter: apartmentFilter,
    );
  }

  R when<R>({
    required R Function(List<ApartmentModel>? apartmentList, Exception? error)
        loaded,
    required R Function() loading,
    required R Function(AppException error) error,
  }) {
    if (loadingState?.exception != null) {
      return error(loadingState!.exception!);
    } else if (loadingState?.isLoading == true) {
      return loading();
    } else {
      return loaded(apartmentList, loadingState?.exception);
    }
  }

  R maybeWhen<R>({
    R Function(List<ApartmentModel>? apartmentList, Exception? error)? loaded,
    R Function()? initial,
    required R Function() orElse,
  }) {
    if (loadingState?.exception != null) {
      return orElse();
    } else if (loadingState?.isLoading == true) {
      return initial != null ? initial() : orElse();
    } else {
      return loaded != null
          ? loaded(apartmentList, loadingState?.exception)
          : orElse();
    }
  }

  @override
  String toString() {
    return 'ApartmentState(apartmentList: $apartmentList)';
  }
}
