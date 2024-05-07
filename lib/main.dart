import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/app/app.dart';
import 'package:nesters/app/bloc/app_bloc_observer.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/auth/firebase_auth_repository_impl.dart';
import 'package:nesters/data/repository/database/local/get_storage_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';

import 'utils/logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  setupLocator();
  Bloc.observer = AppBlocObserver();
  runApp(const RootApp());
}

Future<void> setupFirebase() {
  return Firebase.initializeApp();
}

void setupLocator() {
  GetIt locator = GetIt.instance;
  //============== Auth Repository ==============
  locator.registerSingleton<AuthRepository>(FirebaseAuthRepository());
  //============== Local Storage Repository ==============
  locator.registerSingleton<LocalStorageRepository>(GetStorageRepository());
  //============== Logger Service ==============
  locator.registerSingleton<AppLoggerService>(AppLoggerService());
  //============== User Repository ==============
  locator.registerSingleton<UserRepository>(UserRepository(
    authRepository: locator<AuthRepository>(),
    storageRepository: locator<LocalStorageRepository>(),
  ));
  //============== Navigation Service ==============
  locator.registerSingleton<AppRouterService>(AppRouterService());
  //============== Firestore Repository ==============
  locator.registerSingleton<FirestoreRepository>(FirestoreRepository());
}
