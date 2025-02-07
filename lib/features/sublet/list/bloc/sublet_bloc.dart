import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/sublet/apartment_size.dart';
import 'package:nesters/domain/models/sublet/sublet_filter.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'sublet_state.dart';
part 'sublet_event.dart';

class SubletBloc extends Bloc<SubletEvent, SubletState> {
  SubletBloc() : super(const SubletState()) {
    on<SubletEvent>(_subletEventHandler);
  }

  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();

  FutureOr<void> _subletEventHandler(
      SubletEvent event, Emitter<SubletState> emit) async {
    await event.when(
      initial: () {},
      saveSublets: (sublets) {
        saveSublets(sublets, emit);
      },
      singleAddFilter: (filter) async {
        final filteredSublets =
            await _subletRepository.singleFilterSublet(filter: filter);
        emit(state.copyWith(
            filteredSubletList: filteredSublets, singleSubletFilter: filter));
      },
      singleRemoveFilter: () {
        emit(state.copyWith(singleSubletFilter: null));
      },
      addFilter: (filter) async {
        final filteredSublets =
            await _subletRepository.multiFilterSublet(filter: filter);
        _logger.debug(
            "Filtered Sublets: ${filteredSublets.length} with filter: $filter");
        emit(state.copyWith(
            filteredSubletList: filteredSublets, subletFilter: filter));
      },
      removeFilter: () {
        emit(state.copyWith(subletFilter: null));
      },
    );
  }

  void saveSublets(List<SubletModel> sublets, Emitter<SubletState> emit) {}
}
