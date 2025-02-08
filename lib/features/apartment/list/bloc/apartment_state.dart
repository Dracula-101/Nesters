part of 'apartment_bloc.dart';

class ApartmentState {
  final List<ApartmentModel>? apartmentList;
  final List<ApartmentModel>? filteredApartmentList;
  final Exception? error;
  // Single category of apartment filtering
  final SingleApartmentFilter? singleApartmentFilter;
  final ApartmentFilter? apartmentFilter;

  const ApartmentState({
    this.apartmentList,
    this.filteredApartmentList,
    this.error,
    this.singleApartmentFilter,
    this.apartmentFilter,
  });

  ApartmentState copyWith({
    List<ApartmentModel>? apartmentList,
    List<ApartmentModel>? filteredApartmentList,
    Exception? error,
    SingleApartmentFilter? singleApartmentFilter,
    ApartmentFilter? apartmentFilter,
  }) {
    return ApartmentState(
      apartmentList: apartmentList ?? this.apartmentList,
      filteredApartmentList:
          filteredApartmentList ?? this.filteredApartmentList,
      error: error ?? this.error,
      singleApartmentFilter: singleApartmentFilter,
      apartmentFilter: apartmentFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApartmentState &&
        listEquals(other.apartmentList, apartmentList) &&
        other.error == error &&
        other.singleApartmentFilter == singleApartmentFilter &&
        listEquals(other.filteredApartmentList, filteredApartmentList) &&
        other.apartmentFilter == apartmentFilter;
  }

  @override
  int get hashCode => apartmentList.hashCode ^ error.hashCode;

  R when<R>({
    required R Function(List<ApartmentModel>? apartmentList, Exception? error)
        loaded,
    required R Function() initial,
  }) {
    if (apartmentList != null) {
      return loaded(apartmentList, error);
    } else {
      return initial();
    }
  }

  R maybeWhen<R>({
    R Function(List<ApartmentModel>? apartmentList, Exception? error)? loaded,
    R Function()? initial,
    required R Function() orElse,
  }) {
    if (apartmentList != null) {
      return loaded != null ? loaded(apartmentList, error) : orElse();
    } else {
      return initial != null ? initial() : orElse();
    }
  }

  @override
  String toString() {
    return 'ApartmentState(apartmentList: $apartmentList, error: $error)';
  }
}
