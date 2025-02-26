part of 'apartment_bloc.dart';

class ApartmentState extends Equatable {
  final List<ApartmentModel>? apartmentList;
  final List<ApartmentModel>? filteredApartmentList;
  final BlocState filterState;
  // Single category of apartment filtering
  final SingleApartmentFilter? singleApartmentFilter;
  final ApartmentFilter? apartmentFilter;

  const ApartmentState({
    this.apartmentList,
    this.filteredApartmentList,
    this.singleApartmentFilter,
    this.filterState = const BlocState(isLoading: false),
    this.apartmentFilter,
  });

  ApartmentState copyWith({
    List<ApartmentModel>? apartmentList,
    List<ApartmentModel>? filteredApartmentList,
    BlocState? filterState,
    SingleApartmentFilter? singleApartmentFilter,
    ApartmentFilter? apartmentFilter,
  }) {
    return ApartmentState(
      apartmentList: apartmentList ?? this.apartmentList,
      filteredApartmentList:
          filteredApartmentList ?? this.filteredApartmentList,
      filterState: filterState ?? this.filterState,
      singleApartmentFilter: singleApartmentFilter,
      apartmentFilter: apartmentFilter,
    );
  }

  @override
  String toString() {
    return 'ApartmentState(apartmentList: $apartmentList)';
  }

  @override
  List<Object?> get props => [
        apartmentList,
        filteredApartmentList,
        filterState,
        singleApartmentFilter,
        apartmentFilter,
      ];
}
