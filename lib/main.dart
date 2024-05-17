import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/data/repository/user/chat/fireabase_chat_repository.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/data/repository/user/status/firebase_user_status_repository.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nesters/app/app.dart';
import 'package:nesters/app/bloc/app_bloc_observer.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/supabase_auth_repository_impl.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/data/repository/database/local/get_storage_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/utils/logger/logger.dart';

import 'data/repository/database/remote/supadatabase_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await initalizeApp();
  Bloc.observer = AppBlocObserver();
  runApp(const RootApp());
}

Future<void> setupFirebase() {
  return Firebase.initializeApp();
}

Future<void> setupSupabase(AppSecretsRepository appSecrets) {
  return Supabase.initialize(
    url: appSecrets.getSecret(AppSecretsKeys.SUPABASE_URL),
    anonKey: appSecrets.getSecret(AppSecretsKeys.SUPABASE_ANON_KEY),
    debug: false,
  );
}

Future<void> initalizeApp() async {
  AppSecretsRepository appSecrets = AppSecretsRepository();
  await appSecrets.init();
  setupSupabase(appSecrets);
  setupLocator(appSecrets);
}

void setupLocator(AppSecretsRepository appSecretsRepository) {
  GetIt locator = GetIt.instance;
  // Initalize All repositories
  LocalStorageRepository localStorageRepository = GetStorageRepository();
  AppLoggerService appLoggerService = AppLoggerService();
  MediaRepository mediaRepository = MediaRepository();
  AppRouterService appRouterService = AppRouterService();
  AuthRepository authRepository =
      SupabaseAuthRepository(appSecretsRepository: appSecretsRepository);
  DatabaseRepository databaseRepository = SupaDatabaseRepository();
  RemoteChatRepository remoteChatRepository = FirebaseChatRepository();
  UserRepository userRepository = UserRepository(
    databaseRepository: databaseRepository,
    storageRepository: localStorageRepository,
    logger: appLoggerService,
  );
  UserStatusRepository userStatusRepository = FirebaseUserStatusRepository();
  // Register all repositories
  locator.registerSingleton<LocalStorageRepository>(localStorageRepository);
  locator.registerSingleton<AppLoggerService>(appLoggerService);
  locator.registerSingleton<AppRouterService>(appRouterService);
  locator.registerSingleton<MediaRepository>(mediaRepository);
  locator.registerSingleton<AuthRepository>(authRepository);
  locator.registerSingleton<DatabaseRepository>(databaseRepository);
  locator.registerSingleton<UserRepository>(userRepository);
  locator.registerSingleton<RemoteChatRepository>(remoteChatRepository);
  locator.registerSingleton<UserStatusRepository>(userStatusRepository);
}
