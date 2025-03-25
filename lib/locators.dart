import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_places_sdk/google_places_sdk.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/apartment/apartment_repository_impl.dart';
import 'package:nesters/data/repository/crash_services/crash_services_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository_impl.dart';
import 'package:nesters/data/repository/media/media_compressor.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository_impl.dart';
import 'package:nesters/data/repository/user/chat/firebase_chat_repository.dart';
import 'package:nesters/data/repository/user/profile/firebase_user_profile_repository.dart';
import 'package:nesters/data/repository/user/profile/user_chat_profile_repository.dart';
import 'package:nesters/data/repository/user/user_repository_impl.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:get_it/get_it.dart';

import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository_impl.dart';
import 'package:nesters/data/repository/device/device_info_repository.dart';
import 'package:nesters/data/repository/device/device_info_repository_impl.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/data/repository/network/network_checker_repository.dart';
import 'package:nesters/data/repository/network/network_checker_repository_impl.dart';
import 'package:nesters/data/repository/user/chat/remote_chat_repository.dart';
import 'package:nesters/data/repository/notification/local/local_notification_repository.dart';
import 'package:nesters/data/repository/notification/remote/firebase_notification_repository.dart';
import 'package:nesters/data/repository/notification/remote/remote_notification_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/firebase_recipient_user_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/data/repository/user/status/firebase_user_status_repository.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/supabase_auth_repository_impl.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/data/repository/database/local/get_storage_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';

Future<void> setupLocator(AppSecretsRepository appSecretsRepository) async {
  GetIt locator = GetIt.instance;
  // Initalize All repositories
  AppLogger appLoggerService = AppLogger();
  LocalStorageRepository localStorageRepository = GetStorageRepository();
  MediaCompressor mediaCompressor = MediaCompressor();
  MediaRepository mediaRepository = MediaRepository();
  NetworkCheckerRepository networkCheckerRepository =
      NetworkCheckerRepositoryImpl()..init();
  DeviceInfoRepository deviceInfoRepository = DeviceInfoRepositoryImpl();
  unawaited(deviceInfoRepository.intializeAppCheck());
  AppRouterService appRouterService = AppRouterService();
  AuthRepository authRepository =
      SupabaseAuthRepository(appSecretsRepository: appSecretsRepository);
  RemoteChatRepository remoteChatRepository = FirebaseChatRepository();
  RecipientUserRepository firebaseRecipientQuickUserRepository =
      FirebaseRecipientUserRepository();
  GooglePlaces googlePlaces = GooglePlaces();
  await googlePlaces.initialize(
    appSecretsRepository.getSecret(
      Platform.isAndroid
          ? AppSecretsKeys.GOOGLE_ANDROID_PLACES_API_KEY
          : AppSecretsKeys.GOOGLE_IOS_PLACES_API_KEY,
    ),
    locale: const Locale('en'),
  );
  UserRepository userRepository = UserRepositoryImpl(
    authRepository: authRepository,
    storageRepository: localStorageRepository,
    logger: appLoggerService,
    placesRepository: googlePlaces,
  );
  UserChatProfileRepository userChatRepository =
      FirebaseUserChatProfileRepository();
  UserStatusRepository userStatusRepository = FirebaseUserStatusRepository();
  LocalNotificationRepository notificationRepository =
      LocalNotificationRepository(
          appRouterService: appRouterService, mediaRepository: mediaRepository);
  RemoteNotificationRepository remoteNotificationRepository =
      FirebaseNotificationRepository(
    notificationRepository: notificationRepository,
    appRouterService: appRouterService,
  )..listenToNotification();
  ObxStorageRepository objectbox = ObjectBoxStorageRepository();
  SubletRepository subletRepository =
      SubletRepositoryImpl(logger: appLoggerService);
  ApartmentRepository apartmentRepository =
      ApartmentRepositoryImpl(logger: appLoggerService);
  MarketplaceRepository marketplaceRepository =
      MarketplaceRepositoryImpl(logger: appLoggerService);
  CrashServiceRepository crashServiceRepository = CrashServiceRepository();

  // Register all repositories
  locator.registerSingleton(appSecretsRepository);
  locator.registerSingleton(appLoggerService);
  locator.registerSingleton(googlePlaces);
  locator.registerSingleton(mediaCompressor);
  locator.registerSingleton(localStorageRepository);
  locator.registerSingleton(appRouterService);
  locator.registerSingleton(deviceInfoRepository);
  locator.registerSingleton(networkCheckerRepository);
  locator.registerSingleton(mediaRepository);
  locator.registerSingleton(authRepository);
  locator.registerSingleton(userRepository);
  locator.registerSingleton(remoteChatRepository);
  locator.registerSingleton(userChatRepository);
  locator.registerSingleton(firebaseRecipientQuickUserRepository);
  locator.registerSingleton(userStatusRepository);
  locator.registerSingleton(notificationRepository);
  locator.registerSingleton(remoteNotificationRepository);
  locator.registerSingleton(objectbox);
  locator.registerSingleton(marketplaceRepository);
  locator.registerSingleton(subletRepository);
  locator.registerSingleton(apartmentRepository);
  locator.registerSingleton(crashServiceRepository);
}
