import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/error/auth_error.dart';
import 'package:nesters/data/repository/crash_services/crash_services_repository.dart';
import 'package:nesters/data/repository/user/profile/user_chat_profile_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<AuthEvent>(_onEvent);
    initializeAuthListener();
  }

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final CrashServiceRepository _crashServiceRepository =
      GetIt.I<CrashServiceRepository>();
  final UserRepository _userRepository = GetIt.I<UserRepository>();
  final UserChatProfileRepository _userChatRepository =
      GetIt.I<UserChatProfileRepository>();
  final AppLogger _loggerService = GetIt.I<AppLogger>();

  Future<void> _onEvent(
    AuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    await event.when(
      authUserChanged: (user) async {
        _onUserChanged(user, emit);
      },
      authAppleSignIn: () async => await _onAppleSignIn(emit),
      authGoogleSignIn: () async => await _onGoogleSignIn(emit),
      authSignOut: () async => await _onSignOut(emit),
      deleteAccount: () async => await _onDeleteAccount(emit),
    );
  }

  Future<void> _onGoogleSignIn(
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.googleSignInLoading());
      await _authRepository.signInWithGoogle();
    } on AuthException catch (error) {
      _loggerService.error(error);
      emit(AuthState.error(error));
    }
  }

  Future<void> _onAppleSignIn(
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.appleSignInLoading());
      await _authRepository.signInWithApple();
    } on AuthException catch (error) {
      _loggerService.error(error);
      emit(AuthState.error(error));
    }
  }

  Future<void> _onSignOut(
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
    } on AuthException catch (error) {
      _loggerService.error(error);
      emit(AuthState.error(error));
    }
  }

  void _onUserChanged(
    User? user,
    Emitter<AuthState> emit,
  ) {
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  void initializeAuthListener() {
    _authRepository.user.listen((user) {
      add(AuthEvent.authUserChanged(user));
    });
  }

  Future<void> _onDeleteAccount(
    Emitter<AuthState> emit,
  ) async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      _loggerService.error("User id is null");
    }
    try {
      await _userRepository.softDeleteAccount();
      await _userChatRepository.deleteUser(userId!);
      add(const AuthEvent.authSignOut());
    } on AppException catch (error) {
      _loggerService.error(error);
      emit(AuthState.error(error));
    }
  }
}

class AuthUser {
  final User? user;
  final bool? isUserProfileCreated;

  AuthUser({this.user, this.isUserProfileCreated});
}
