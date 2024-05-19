import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/notification/local/local_notification_repository.dart';
import 'package:nesters/data/repository/notification/remote/remote_notification_repository.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/status/status.dart';
import 'package:nesters/domain/models/user/user.dart';
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
        loaded: (isSuccessful, _) => _loadedApp(event, emit, isSuccessful),
      );
    });
    add(const AppEvent.load());
  }

  final AppLoggerService _loggerService =
      GetIt.instance.get<AppLoggerService>();
  final AuthRepository _authRepository = GetIt.instance.get<AuthRepository>();
  final UserStatusRepository _userStatusRepository =
      GetIt.instance.get<UserStatusRepository>();
  final UserRepository _userRepository = GetIt.instance.get<UserRepository>();
  final RemoteNotificationRepository _rNotificationRepository =
      GetIt.instance.get<RemoteNotificationRepository>();

  final LocalStorageRepository _localStorageRepository =
      GetIt.instance.get<LocalStorageRepository>();
  final ObxStorageRepository _obxStorageRepository =
      GetIt.instance.get<ObxStorageRepository>();
  final LocalNotificationRepository _localNotificationRepository =
      GetIt.instance.get<LocalNotificationRepository>();
  AppLifecycleListener? _appLifecycleListener;
  String? userId;
  bool isCompletedOnboarding = false;
  NavigationArgs? initalizationArgs;

  Future<void> _loadApp(AppEvent event, Emitter<AppState> emit) async {
    emit(const AppState.loadInProgress());
    try {
      final repositoryIntialize = await Future.wait([
        _localStorageRepository.init().timeInMilliseconds,
        _obxStorageRepository.init().timeInMilliseconds,
        _localNotificationRepository.init().timeInMilliseconds,
      ]);
      int totalIntializationTime = 0;
      for (int time in repositoryIntialize) {
        totalIntializationTime += time.isNegative ? 0 : time;
      }
      isCompletedOnboarding = _userRepository.checkUserOnboardingStatus();
      unawaited(loadAndSaveToken());
      int totalUnusedTime = (1500 - totalIntializationTime).isNegative
          ? 0
          : (1500 - totalIntializationTime);
      await Future.delayed(totalUnusedTime.ms);
      _loggerService
          .info('Repository Intialized in : $totalIntializationTime ms');
      add(AppEvent.loaded(
          isSuccessful: true, isOnboaringComplete: isCompletedOnboarding));
    } catch (e) {
      _loggerService.error('Error loading app: $e');
      emit(const AppState.loadFailure());
    }
  }

  Future<void> loadAndSaveToken() async {
    try {
      String token = await _rNotificationRepository.getToken();
      _loggerService.info('Token: $token');
      await _localStorageRepository.saveString(
          token, LocalStorageKeys.userToken);
    } catch (e) {
      _loggerService.error('Error loading token: $e');
    }
  }

  void _loadedApp(AppEvent event, Emitter<AppState> emit, bool isSuccessful) {
    _authRepository.user
        .asyncMap(_checkUserProfileCreated)
        .listen(_authHandler);
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
    userId ??= user?.id;
    _intializeNavigationHandler(
        user != null, isCompletedOnboarding, user?.isProfileCreated ?? false);
    _initalizeAppLifecycleListener(user != null);
    _checkNotificationPermission(user);
    _addNotificationListener(user);
    _handleLocalStorage(user);
  }

  Future<User?> _checkUserProfileCreated(User? user) async {
    if (user == null) return null;
    bool isProfileCreated =
        await _userRepository.checkUserCreated(user.id) ?? false;
    _loggerService.info('User Profile Created: $isProfileCreated');
    user = user.copyWith(isProfileCreated: isProfileCreated);
    return user;
  }

  void _intializeNavigationHandler(
      bool isLoggedIn, bool isOnboardingComplete, bool isUserProfileCreated) {
    String? route;
    if (!isOnboardingComplete) {
      route = AppRouterService.onboardingScreen;
    } else if (!isLoggedIn) {
      route = AppRouterService.loginScreen;
    } else if (!isUserProfileCreated) {
      route = AppRouterService.userProfileBasicFormScreen;
    } else {
      if (initalizationArgs != null) {
        route = initalizationArgs?.route;
        initalizationArgs = null;
      }
      route ??= AppRouterService.homeScreen;
    }
    // route = AppRouterService.homeScreen;
    _loggerService.info('Initial Route: $route');
    AppRouterService.navigatorKey.currentContext!.go(route);
  }

  void _initalizeAppLifecycleListener(bool isLoggedIn) {
    if (!isLoggedIn) {
      if (userId != null) {
        unawaited(
            _userStatusRepository.updateUserStatus(Status.OFFLINE, userId!));
      }
      _appLifecycleListener?.dispose();
      _appLifecycleListener = null;
    } else {
      unawaited(_userStatusRepository.updateUserStatus(Status.ONLINE, userId!));
      _appLifecycleListener ??= AppLifecycleListener(
        onExitRequested: () async {
          if (userId == null) return AppExitResponse.exit;
          await _userStatusRepository.updateUserStatus(Status.OFFLINE, userId!);
          return AppExitResponse.exit;
        },
        onStateChange: (lifecycleState) {
          if (lifecycleState == AppLifecycleState.resumed) {
            if (userId == null) return;
            _userStatusRepository.updateUserStatus(Status.ONLINE, userId!);
          } else if (lifecycleState == AppLifecycleState.paused) {
            if (userId == null) return;
            _userStatusRepository.updateUserStatus(Status.OFFLINE, userId!);
          }
        },
      );
    }
  }

  FutureOr<void> _checkNotificationPermission(User? user) async {
    if (user != null) {
      _rNotificationRepository.init();
      String? token =
          _localStorageRepository.getString(LocalStorageKeys.userToken);
      if (token == null) {
        token = await _rNotificationRepository.getToken();
        unawaited(_localStorageRepository.saveString(
            token, LocalStorageKeys.userToken));
      }
      bool isSavedData =
          _localStorageRepository.getBool(LocalStorageKeys.userDataSaved) ??
              false;
      if (!isSavedData) {
        _rNotificationRepository
            .saveData(
          userId: user.id,
          fullName: user.fullName,
          photoUrl: user.photoUrl,
          token: token,
        )
            .then((value) {
          _localStorageRepository.saveBool(
              LocalStorageKeys.userDataSaved, true);
        });
      }
    }
  }

  void _addNotificationListener(User? user) {
    if (user != null) {
      _rNotificationRepository.listenToNotification();
    } else {
      _rNotificationRepository.removeNotificationListener();
    }
  }

  void _handleLocalStorage(User? user) {
    if (user == null) {
      unawaited(_localStorageRepository.clear());
    }
  }
}

abstract class NavigationArgs {
  final String? route;
  final Map<String, dynamic>? args;
  NavigationArgs({this.route, this.args});
}

class ChatNavigationArgs implements NavigationArgs {
  @override
  final String route;
  @override
  final Map<String, dynamic> args;

  final String? chatId;
  final User? user;

  ChatNavigationArgs({required this.chatId, required this.user})
      : route =
            '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/$chatId',
        args = {'chatId': chatId, 'user': user};
}
