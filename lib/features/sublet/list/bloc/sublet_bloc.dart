import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';

part 'sublet_state.dart';
part 'sublet_event.dart';

class SubletBloc extends Bloc<SubletEvent, SubletState> {
  SubletBloc() : super(const SubletState()) {
    on<SubletEvent>(_subletEventHandler);
  }

  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();

  FutureOr<void> _subletEventHandler(
      SubletEvent event, Emitter<SubletState> emit) async {
    event.when(
      initial: () {},
      saveSublets: (sublets) {
        saveSublets(sublets, emit);
      },
    );
  }

  void saveSublets(List<SubletModel> sublets, Emitter<SubletState> emit) {}
}
