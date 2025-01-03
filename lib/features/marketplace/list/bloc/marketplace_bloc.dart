import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';

part 'marketplace_state.dart';
part 'marketplace_event.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc() : super(const MarketplaceState()) {
    on<MarketplaceEvent>(_marketplaceEventHandler);
  }

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();

  FutureOr<void> _marketplaceEventHandler(
      MarketplaceEvent event, Emitter<MarketplaceState> emit) async {
    await event.when(
        initial: () {},
        saveMarketplaces: (marketplaces) {
          saveMarketplaces(marketplaces, emit);
        },
        applySingleFilter: (filter) async {
          final filteredMarketplaces = await _marketplaceRepository
              .getSingleFilteredMarketplaces(filter);
          emit(state.copyWith(
              marketplaceListFiltered: filteredMarketplaces, filter: filter));
        },
        removeSingleFilter: () {
          emit(state.copyWith(filter: null, marketplaceListFiltered: null));
        });
  }

  void saveMarketplaces(
      List<MarketplaceModel> marketplaces, Emitter<MarketplaceState> emit) {}
}
