import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'marketplace_state.dart';
part 'marketplace_event.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc() : super(const MarketplaceState()) {
    on<MarketplaceEvent>(_marketplaceEventHandler);
  }

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();

  final AppLogger _logger = GetIt.I<AppLogger>();

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  FutureOr<void> _marketplaceEventHandler(
      MarketplaceEvent event, Emitter<MarketplaceState> emit) async {
    final userId = _authRepository.currentUser!.id;
    await event.when(
      initial: () {},
      saveMarketplaces: (marketplaces) {
        saveMarketplaces(marketplaces, emit);
      },
      applySingleFilter: (filter) async {
        try {
          emit(state.copyWith(
            filterState: state.filterState.loading(),
            filter: filter,
          ));
          final filteredMarketplaces = await _marketplaceRepository
              .getSingleFilteredMarketplaces(filter, userId);
          emit(state.copyWith(
            marketplaceListFiltered: filteredMarketplaces,
            filter: filter,
            filterState: state.filterState.success(),
          ));
        } on AppException catch (e) {
          emit(state.copyWith(
            filterState: state.filterState.failure(e),
            filter: null,
          ));
        }
      },
      removeSingleFilter: () {
        emit(state.copyWith(filter: null, marketplaceListFiltered: null));
      },
      addMultipleFilter: (filter) async {
        try {
          emit(state.copyWith(
            filterState: state.filterState.loading(),
            advancedFilter: filter,
          ));
          final filteredMarketplaces = await _marketplaceRepository
              .getMultipleFilteredMarketplaces(filter, userId);
          emit(state.copyWith(
            marketplaceListFiltered: filteredMarketplaces,
            advancedFilter: filter,
            filterState: state.filterState.success(),
          ));
        } on AppException catch (e) {
          emit(state.copyWith(
            filterState: state.filterState.failure(e),
            advancedFilter: null,
          ));
        }
      },
      removeMultipleFilter: () {
        emit(state.copyWith(
            filter: null, marketplaceListFiltered: null, advancedFilter: null));
      },
    );
  }

  void saveMarketplaces(
      List<MarketplaceModel> marketplaces, Emitter<MarketplaceState> emit) {}
}
