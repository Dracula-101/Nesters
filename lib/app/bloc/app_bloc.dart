import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/crash_services/crash_services_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/device/device_info_repository.dart';
import 'package:nesters/data/repository/notification/local/local_notification_repository.dart';
import 'package:nesters/data/repository/network/network_checker_repository.dart';
import 'package:nesters/data/repository/notification/remote/remote_notification_repository.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'app_state.dart';
part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppEvent>((event, emit) async {
      event.when(
        load: () => _loadApp(event, emit),
        loaded: (isSuccessful, isOnboaringComplete) =>
            _loadedApp(event, emit, isSuccessful),
        networkChange: (data, isOnline) =>
            _handleNetworkChange(emit, data, isOnline),
      );
    });
    add(const AppEvent.load());
    _addNetworkListener();
  }

  final AppLogger _loggerService = GetIt.instance.get<AppLogger>();
  final _authRepository = GetIt.instance.get<AuthRepository>();
  final _userRepository = GetIt.instance.get<UserRepository>();
  final _localStorageRepository = GetIt.instance.get<LocalStorageRepository>();
  final _obxStorageRepository = GetIt.instance.get<ObxStorageRepository>();
  final _deviceInfoRepository = GetIt.instance.get<DeviceInfoRepository>();
  final _remoteChatRepository = GetIt.instance.get<RemoteChatRepository>();
  final _crashServiceRepository = GetIt.instance.get<CrashServiceRepository>();

  final _localNotificationRepository =
      GetIt.instance.get<LocalNotificationRepository>();
  final _rNotificationRepository =
      GetIt.instance.get<RemoteNotificationRepository>();
  final _networkCheckerRepository =
      GetIt.instance.get<NetworkCheckerRepository>();

  String? userId;
  bool isOnboardingCompleted = false;
  NavigationArgs? initializationArgs;

  Future<void> _loadApp(AppEvent event, Emitter<AppState> emit) async {
    emit(const AppState(isLoading: true));
    try {
      final repositoryIntialize = await Future.wait([
        _localStorageRepository.init().timeInMilliseconds,
        _obxStorageRepository.init().timeInMilliseconds,
        _localNotificationRepository.init().timeInMilliseconds,
        _deviceInfoRepository.init().timeInMilliseconds,
      ]);
      isOnboardingCompleted = _userRepository.checkUserOnboardingStatus();
      unawaited(loadAndSaveToken());
      _remoteChatRepository.tokenChangeListener();
      _loggerService.info(
          "Local Storage: ${repositoryIntialize[0]} ms\nObject Box: ${repositoryIntialize[1]} ms\nLocal Notification: ${repositoryIntialize[2]} ms\nDevice Info: ${repositoryIntialize[3]} ms");
      add(AppEvent.loaded(
          isSuccessful: true, isOnboaringComplete: isOnboardingCompleted));
    } on Exception catch (error, stacktrace) {
      _loggerService.error('Error loading app: $error');
      _crashServiceRepository.recordError(error, stackTrace: stacktrace);
      add(const AppEvent.loaded(
          isSuccessful: false, isOnboaringComplete: false));
    }
  }

  void _addNetworkListener() {
    _networkCheckerRepository.init();
    _networkCheckerRepository.networkStatusStream.asBroadcastStream().listen(
      (event) {
        add(AppEvent.networkChange(
          data: event.networkData,
          isOnline: event.isOnline,
        ));
      },
    );
  }

  Future<void> loadAndSaveToken() async {
    try {
      String token = await _rNotificationRepository.getToken();
      _loggerService.info(
          'Token: ${token.substring(0, 10)}******************************');
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
      emit(const AppState(isLoading: false));
    } else {
      emit(AppState(error: Exception('Error loading app)'), isLoading: false));
    }
  }

  void _authHandler(User? user) {
    //here we will handle the user authentication, and navigate to the appropriate screen, and more...
    if (user != null) {
      _loggerService.info('User is logged in - ${user.email}');
    } else {
      _loggerService.info('User is not logged in');
    }
    userId ??= user?.id;
    _intializeNavigationHandler(
        user != null, isOnboardingCompleted, user?.isProfileCreated ?? false);
    // _initalizeAppLifecycleListener(user != null);
    _initializeNotificationSettings(user);
    _saveDeviceInfo(user);
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
    //used for initial routing when the app is loaded
    String? route;
    if (!isOnboardingComplete) {
      route = AppRouterService.onboardingScreen;
    } else if (!isLoggedIn) {
      route = AppRouterService.loginScreen;
    } else if (!isUserProfileCreated) {
      route = AppRouterService.userProfileBasicFormScreen;
    } else {
      if (initializationArgs != null) {
        route = initializationArgs?.route;
        initializationArgs = null;
      }
      route ??= AppRouterService.homeScreen;
    }
    // route = AppRouterService.homeScreen;
    _loggerService.info('Initial Route: $route');
    AppRouterService.navigatorKey.currentContext!.go(route);
  }

  // Note: Remove after adding sockets
  // void _initalizeAppLifecycleListener(bool isLoggedIn) {
  //   if (!isLoggedIn) {
  //     if (userId != null) {
  //       unawaited(
  //           _userStatusRepository.updateUserStatus(Status.OFFLINE, userId!));
  //     }
  //     _appLifecycleListener?.dispose();
  //     _appLifecycleListener = null;
  //   } else {
  //     unawaited(_userStatusRepository.updateUserStatus(Status.ONLINE, userId!));
  //     _appLifecycleListener ??= AppLifecycleListener(
  //       onExitRequested: () async {
  //         if (userId == null) return AppExitResponse.exit;
  //         await _userStatusRepository.updateUserStatus(Status.OFFLINE, userId!);
  //         return AppExitResponse.exit;
  //       },
  //       onStateChange: (lifecycleState) {
  //         if (lifecycleState == AppLifecycleState.resumed) {
  //           if (userId == null) return;
  //           _userStatusRepository.updateUserStatus(Status.ONLINE, userId!);
  //         } else if (lifecycleState == AppLifecycleState.paused) {
  //           if (userId == null) return;
  //           _userStatusRepository.updateUserStatus(Status.OFFLINE, userId!);
  //         }
  //       },
  //     );
  //   }
  // }

  void _saveDeviceInfo(User? user) {
    /// This function saves the device information for a user if it has not been saved previously.
    ///
    /// It performs the following steps:
    /// 1. Checks if the device information has already been saved to local storage.
    /// 2. If not, and if the user is not null, it saves the device information using the device info repository.
    /// 3. Once the device information is successfully saved, it updates local storage to indicate that the device information has been saved.
    bool isDeviceInfoSaved =
        _localStorageRepository.getBool(LocalStorageKeys.deviceInfoSaved) ??
            false;
    if (!isDeviceInfoSaved && user != null) {
      unawaited(_deviceInfoRepository.saveDeviceInfo(user.id).whenComplete(() {
        unawaited(_localStorageRepository.saveBool(
            LocalStorageKeys.deviceInfoSaved, true));
      }));
    }
  }

  FutureOr<void> _initializeNotificationSettings(User? user) async {
    /// This function handles the initialization and configuration of notification settings for a user.
    ///
    /// It performs the following steps:
    /// 1. Initializes the notification repository.
    /// 2. Checks if a notification token is stored in local storage. If not, retrieves a new token from the repository and saves it to local storage.
    /// 3. Checks if the user's data has already been saved to local storage. If not, saves the user data to the notification repository and updates local storage.
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
            .then(
          (value) {
            _localStorageRepository.saveBool(
              LocalStorageKeys.userDataSaved,
              true,
            );
          },
        );
      }
    }
  }

  void _addNotificationListener(User? user) {
    /// Adds or removes notification listener based on the presence of the user.
    ///
    /// This function performs the following actions:
    /// 1. If a user is provided, it adds a listener to receive notifications using the notification repository.
    /// 2. If no user is provided (i.e., user is null), it removes the notification listener.
    if (user != null) {
      _rNotificationRepository.listenToNotification();
    } else {
      _rNotificationRepository.removeNotificationListener();
    }
  }

  void _handleLocalStorage(User? user) {
    /// Handles local storage based on the presence of the user.
    ///
    /// This function performs the following action:
    /// 1. If no user is provided (i.e., user is null), it clears the local storage.
    if (user == null) {
      unawaited(_localStorageRepository.clear());
    }
  }

  void _handleNetworkChange(
    Emitter<AppState> emit,
    NetworkData data,
    bool isOnline,
  ) {
    emit(AppState(networkData: data, isOnline: isOnline));
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
