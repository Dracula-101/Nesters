import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nesters/app/app.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/data/repository/notification/local/local_notification_repository.dart';
import 'package:nesters/locators.dart';
import 'package:nesters/app/bloc/app_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await initalizeApp();
  setupMessaging();
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  GetIt locator = GetIt.instance;
  LocalNotificationRepository notificationRepository =
      locator<LocalNotificationRepository>();
  notificationRepository.showNotification(
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    payload: json.encode(message.data),
  );
}

Future<void> initalizeApp() async {
  AppSecretsRepository appSecrets = AppSecretsRepository();
  await appSecrets.init();
  setupSupabase(appSecrets);
  await setupLocator(appSecrets);
}

void setupMessaging() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}
