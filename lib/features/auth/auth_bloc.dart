import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/error/auth_error.dart';
import 'package:nesters/domain/models/user.dart';

part 'auth_state.dart';
part 'auth_event.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    on<AuthGoogleSiginInEvent>(_onGoogleSignIn);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthUserChangedEvent>(_onUserChanged);
  }

  final AuthRepository _authRepository;

  void _onGoogleSignIn(
    AuthGoogleSiginInEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState.loading());
    _authRepository.signInWithGoogle().catchError(
      (error) {
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
    emit(const AuthState.loading());
    _authRepository.signOut().catchError(
      (error) {
        emit(const AuthState.error("Couldn't sign out"));
      },
    );
  }

  void _onUserChanged(
    AuthUserChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState.loading());
    _authRepository.user.listen(
      (user) {
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }
}
