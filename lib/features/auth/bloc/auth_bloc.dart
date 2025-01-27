import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/error/auth_error.dart';
import 'package:nesters/data/repository/crash_services/crash_services_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
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
  final AppLogger _loggerService = GetIt.I<AppLogger>();

  Future<void> _onEvent(
    AuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    await event.when(
      authUserChanged: (user) async {
        _onUserChanged(user, emit);
      },
      authGoogleSignIn: () async => await _onGoogleSignIn(emit),
      authSignOut: () async => await _onSignOut(emit),
      deleteAccount: () async => await _onDeleteAccount(),
    );
  }

  Future<void> _onGoogleSignIn(
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.loading());
      await _authRepository.signInWithGoogle();
    } on Exception catch (error, stackTrace) {
      _loggerService.error(error);
      if (error is GoogleSignInFailedException) {
        emit(AuthState.error(error.localizedMessage));
      } else {
        _crashServiceRepository.recordError(error, stackTrace: stackTrace);
        if (error is AuthSignInError) {
          emit(AuthState.error(error.message));
        } else {
          emit(AuthState.error(error.toString()));
        }
      }
    }
  }

  Future<void> _onSignOut(
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut().catchError(
      (error) {
        _loggerService.error(error);
        emit(const AuthState.error("Couldn't sign out"));
      },
    );
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

  Future<void> _onDeleteAccount() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      _loggerService.error("User id is null");
    }
    try {
      _userRepository.softDeleteAccount();
      add(const AuthEvent.authSignOut());
    } catch (error) {
      _loggerService.error(error);
    }
  }
}

class AuthUser {
  final User? user;
  final bool? isUserProfileCreated;

  AuthUser({this.user, this.isUserProfileCreated});
}
