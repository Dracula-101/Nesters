import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/user.dart';

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
      );
    });
    add(const SettingsEvent.loadProfile());
    _addUserListener();
  }

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  void _addUserListener() {
    _authRepository.userInfo.listen((UserInfo? user) {
      if (user != null) {
        add(const SettingsEvent.loadProfile());
      }
    });
  }
}
