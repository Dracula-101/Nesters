import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/user/user.dart';

part 'user_state.dart';
part 'user_event.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(
    User user,
  ) : super(UserState(user: user)) {
    on<UserEvent>(
      (event, emit) => event.when(
        loadUser: (user) => emit(state.copyWith(user: user)),
        loadUniversities: () async => await _loadUniversities(event, emit),
        loadDegrees: () async => await _loadDegrees(event, emit),
      ),
    );
    add(UserEvent.loadUser(user: user));
    add(const UserEvent.loadUniversities());
    add(const UserEvent.loadDegrees());
  }

  final UserRepository _userRepository = GetIt.I<UserRepository>();

  Future<void> _loadUniversities(UserEvent event, Emitter<UserState> emit) {
    emit(state.copyWith(isLoadingUniversities: true));
    return _userRepository.getAllUniversities().then((universities) {
      if (universities.isNotEmpty) {
        emit(state.copyWith(
            universities: universities, isLoadingUniversities: false));
      } else {
        emit(state.copyWith(isLoadingUniversities: false));
      }
    });
  }

  Future<void> _loadDegrees(UserEvent event, Emitter<UserState> emit) {
    emit(state.copyWith(isLoadingDegrees: true));
    return _userRepository.getAllDegrees().then((degrees) {
      if (degrees.isNotEmpty) {
        emit(state.copyWith(degrees: degrees, isLoadingDegrees: false));
      } else {
        emit(state.copyWith(isLoadingDegrees: false));
      }
    });
  }
}
