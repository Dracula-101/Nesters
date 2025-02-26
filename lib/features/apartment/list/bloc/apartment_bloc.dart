import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/apartment_filter.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'apartment_state.dart';
part 'apartment_event.dart';

class ApartmentBloc extends Bloc<ApartmentEvent, ApartmentState> {
  ApartmentBloc() : super(const ApartmentState()) {
    on<ApartmentEvent>(_apartmentEventHandler);
  }
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final ApartmentRepository _apartmentRepository =
      GetIt.I<ApartmentRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();

  FutureOr<void> _apartmentEventHandler(
      ApartmentEvent event, Emitter<ApartmentState> emit) async {
    final userId = _authRepository.currentUser!.id;
    await event.when(
      initial: () {},
      saveApartments: (apartments) {
        saveApartments(apartments, emit);
      },
      singleAddFilter: (filter) async {
        try {
          emit(state.copyWith(
            filterState: state.filterState.loading(),
            singleApartmentFilter: filter,
          ));
          final userId = _authRepository.currentUser!.id;
          final filteredApartments =
              await _apartmentRepository.singleFilterApartment(
            filter: filter,
            userId: userId,
          );
          emit(state.copyWith(
            filteredApartmentList: filteredApartments,
            filterState: state.filterState.success(),
            singleApartmentFilter: filter,
          ));
        } on AppException catch (e) {
          emit(state.copyWith(
            filterState: state.filterState.failure(e),
            singleApartmentFilter: null,
          ));
        }
      },
      singleRemoveFilter: () {
        emit(state.copyWith(singleApartmentFilter: null));
      },
      addFilter: (filter) async {
        try {
          emit(state.copyWith(
            filterState: state.filterState.loading(),
            apartmentFilter: filter,
          ));
          final filteredApartments =
              await _apartmentRepository.multiFilterApartment(
            filter: filter,
            userId: userId,
          );
          _logger.debug(
              "Filtered Apartments: ${filteredApartments.length} with filter: $filter");
          emit(state.copyWith(
            filteredApartmentList: filteredApartments,
            filterState: state.filterState.success(),
            apartmentFilter: filter,
          ));
        } on AppException catch (e) {
          emit(state.copyWith(
            filterState: state.filterState.failure(e),
            apartmentFilter: null,
          ));
        }
      },
      removeFilter: () {
        emit(state.copyWith(apartmentFilter: null));
      },
    );
  }

  void saveApartments(
      List<ApartmentModel> apartments, Emitter<ApartmentState> emit) {}
}
