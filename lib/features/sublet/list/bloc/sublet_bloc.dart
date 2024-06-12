import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';

part 'sublet_state.dart';
part 'sublet_event.dart';
part 'sublet_bloc.freezed.dart';

class SubletBloc extends Bloc<SubletEvent, SubletState> {
  SubletBloc() : super(SubletState.initial()) {
    on<SubletEvent>(_subletEventHandler);
    add(const SubletEvent.loadSublet());
  }

  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();

  FutureOr<void> _subletEventHandler(
      SubletEvent event, Emitter<SubletState> emit) async {
    await event.when(
      initial: () {},
      loadSublet: () async {
        await loadSublet(emit);
      },
      reloadSublet: () async {
        await loadSublet(emit);
      },
    );
  }

  Future<void> loadSublet(Emitter<SubletState> emit) async {
    emit(SubletState.loading());
    try {
      final List<SubletModel> sublets = await _subletRepository.getSublets();
      emit(state.copyWith(subletList: sublets, isLoading: false));
    } on Exception catch (e) {
      emit(SubletState.error(e));
    }
  }

  Future<void> refreshSublet() async {
    add(const SubletEvent.loadSublet());
  }
}
