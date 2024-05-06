import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/local_storage/local_storage_repository.dart';
import 'package:nesters/domain/models/user.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'app_state.dart';
part 'app_event.dart';
part 'app_bloc.freezed.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState.initial()) {
    on<AppEvent>((event, emit) async {
      event.when(
        () => null,
        load: () => _loadApp(event, emit),
        loaded: (isSuccessful) => _loadedApp(event, emit, isSuccessful),
      );
    });
    add(const AppEvent.load());
  }

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final LocalStorageRepository _localStorageRepository =
      GetIt.I<LocalStorageRepository>();
  final LoggerService _loggerService = GetIt.I<LoggerService>();

  Future<void> _loadApp(AppEvent event, Emitter<AppState> emit) async {
    emit(const AppState.loadInProgress());
    try {
      int storageInitTime =
          await _localStorageRepository.init().timeInMilliseconds;
      await Future.delayed(const Duration(milliseconds: 1500));
      _loggerService.info('Storage Intialized in : $storageInitTime ms');
      add(const AppEvent.loaded(true));
    } catch (e) {
      _loggerService.error('Error loading app: $e');
      emit(const AppState.loadFailure());
    }
  }

  void _loadedApp(AppEvent event, Emitter<AppState> emit, bool isSuccessful) {
    _authRepository.user.listen(_authHandler);
    if (isSuccessful) {
      emit(const AppState.loadSuccess());
    } else {
      emit(const AppState.loadFailure());
    }
  }

  void _authHandler(User? user) {
    if (user != null) {
      _loggerService.info('User is logged in - ${user.email}');
    } else {
      _loggerService.info('User is not logged in');
    }
    _intializeNavigationHandler(user != null);
  }

  void _intializeNavigationHandler(bool isLoggedIn) {
    AppRouterService.navigatorKey.currentContext!.go(
      isLoggedIn
          ? AppRouterService.homeScreen
          : AppRouterService.onboardingScreen,
    );
  }
}
