import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nesters/utils/logger/logger.dart';

import 'data/repository/database/remote/supadatabase_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initalizeApp();
  await setupFirebase();
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
  //============== Local Storage Repository ==============
  locator.registerSingleton<LocalStorageRepository>(GetStorageRepository());
  //============== Logger Service ==============
  locator.registerSingleton<AppLoggerService>(AppLoggerService());
  //============== Navigation Service ==============
  locator.registerSingleton<AppRouterService>(AppRouterService());
  //============== Firestore Repository ==============
  //locator.registerSingleton<FirestoreRepository>(FirestoreRepository());
  //============== App Secrets ==============
  locator.registerSingleton<AppSecretsRepository>(appSecretsRepository);
  //============== Auth Repository ==============
  locator.registerSingleton<AuthRepository>(SupabaseAuthRepository(
    appSecretsRepository: locator<AppSecretsRepository>(),
  ));
  //============== User Repository ==============
  locator.registerSingleton<UserRepository>(UserRepository(
    authRepository: locator<AuthRepository>(),
    storageRepository: locator<LocalStorageRepository>(),
  ));
  //============== Database Repository ==============
  locator.registerSingleton<DatabaseRepository>(SupaDatabaseRepository());
}
