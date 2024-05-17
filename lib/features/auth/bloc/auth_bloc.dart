import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/error/auth_error.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'auth_state.dart';
part 'auth_event.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<AuthGoogleSiginInEvent>(_onGoogleSignIn);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthUserChangedEvent>(_onUserChanged);
    initializeAuthListener();
  }

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLoggerService _loggerService = GetIt.I<AppLoggerService>();

  Future<void> _onGoogleSignIn(
    AuthGoogleSiginInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    await _authRepository.signInWithGoogle().catchError(
      (error) {
        _loggerService.error(error);
        if (error is GoogleSignInFailedException) {
          emit(AuthState.error(error.localizedMessage));
        } else {
          emit(const AuthState.error("Unknown error"));
        }
      },
    );
  }

  void _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) {
    _authRepository.signOut().catchError(
      (error) {
        _loggerService.error(error);
        emit(const AuthState.error("Couldn't sign out"));
      },
    );
  }

  void _onUserChanged(
    AuthUserChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    final user = event.user;
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  void initializeAuthListener() {
    _authRepository.user.listen((user) {
      add(AuthUserChangedEvent(user));
    });
  }
}

class AuthUser {
  final User? user;
  final bool? isUserProfileCreated;

  AuthUser({this.user, this.isUserProfileCreated});
}
