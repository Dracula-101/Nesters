import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/notification/remote/remote_notification_repository.dart';
import 'package:nesters/domain/models/user/user.dart';

class FirebaseNotificationRepository extends RemoteNotificationRepository {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  StreamSubscription<RemoteMessage>? _onMessageReceived,
      _onNotificationOpenedApp;

  FirebaseNotificationRepository(
      {required super.notificationRepository, required super.appRouterService});

  @override
  Future<bool> init() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: true,
      );
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<String> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        return token;
      } else {
        throw Exception('Token is null');
      }
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> saveData(
      {required String userId,
      required String fullName,
      required String photoUrl,
      required String token}) {
    try {
      return _store.collection('users').doc(userId).set({
        'userId': userId,
        'fullName': fullName,
        'photoUrl': photoUrl,
        'token': token,
      });
    } on Exception {
      rethrow;
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    notificationRepository.showNotification(
      title: message.notification?.title ?? 'Title',
      body: message.notification?.body ?? 'Body',
      payload: jsonEncode(
        message.data,
      ),
    );
  }

  @override
  void listenToTokenChanges(String userId) {
    FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
      log('Token refreshed: $event');
      Map<String, dynamic> userData = await _store
          .collection('users')
          .doc(userId)
          .get()
          .then((value) => value.data() ?? {});
      if (userData.isNotEmpty) {
        await _store.collection('users').doc(userId).update({
          'token': event,
        });
      }
    });
  }

  @override
  void listenToNotification() async {
    _onMessageReceived = FirebaseMessaging.onMessage
        .distinct((a, b) => a.notification?.body == b.notification?.body)
        .listen(null);
    _onNotificationOpenedApp = FirebaseMessaging.onMessageOpenedApp
        .distinct((a, b) => a.notification?.body == b.notification?.body)
        .listen(null);

    // App is in the background when notification is received
    _onMessageReceived?.onData(
      (message) {
        notificationRepository.showNotification(
          title: message.notification?.title ?? 'Title',
          body: message.notification?.body ?? 'Body',
          payload: jsonEncode(
            message.data,
          ),
        );
      },
    );

    // App is opened from notification when user is using the app
    _onNotificationOpenedApp?.onData(
      (message) {
        log("Notification Received in onNotificationOpenedApp: $message");
        String notificationType = message.data['notificationType'];
        if (notificationType == 'chat') {
          log('Chat notification opened: ${message.data}');
          String chatId = message.data['chatId'];
          User userProfile = User(
            id: message.data['senderId'],
            fullName: message.data['senderName'],
            photoUrl: message.data['photoUrl'],
            email: '',
            accessToken: '',
          );
          String currentPath = appRouterService
              .appRouter.routeInformationProvider.value.uri.path;
          if (currentPath.contains(AppRouterService.homeScreen)) {
            appRouterService.appRouter.go(
              '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/$chatId',
              extra: userProfile,
            );
          }
        }
      },
    );
  }

  @override
  void removeNotificationListener() {
    _onMessageReceived?.cancel();
    _onNotificationOpenedApp?.cancel();
  }
}
