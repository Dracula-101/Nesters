import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/utils/bloc_state.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsEvent>((event, emit) async {
      await event.when(
        loadProfile: () {
          final UserInfo? userProfile = _authRepository.currentUserInfo;
          emit(state.copyWith(user: userProfile!));
        },
        changeVisibility: (bool isVisible) async =>
            await _changeUserVisibility(emit, isVisible),
      );
    });
    add(const SettingsEvent.loadProfile());
    _addUserListener();
  }

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final UserRepository _userRepository = GetIt.I<UserRepository>();

  void _addUserListener() {
    _authRepository.userInfo.listen((UserInfo? user) {
      if (user != null) {
        add(const SettingsEvent.loadProfile());
      }
    });
  }

  Future<void> _changeUserVisibility(
      Emitter<SettingsState> emit, bool isVisible) async {
    try {
      emit(state.copyWith(
          userVisibilityState: state.userVisibilityState.loading()));
      UserInfo? user = state.user ?? _authRepository.currentUserInfo;
      String? userId = user?.id ?? _authRepository.currentUser?.id;
      if (userId != null) {
        await _userRepository.updateRoommateFoundStatus(
            id: userId, status: isVisible);
        user = user?.copyWith(hasRoommateFound: isVisible);
        _authRepository.updateUserInfo(user);
        emit(state.copyWith(
            userVisibilityState: state.userVisibilityState.success()));
      } else {
        emit(state.copyWith(
            userVisibilityState:
                state.userVisibilityState.failure(UserNotAuthError())));
      }
    } on AppException catch (e) {
      emit(state.copyWith(
          userVisibilityState: state.userVisibilityState.failure(e)));
    }
  }
}
