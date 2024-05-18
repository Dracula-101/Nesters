import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/notification/local/local_notification_repository.dart';
import 'package:nesters/data/repository/notification/remote/remote_notification_repository.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
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
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
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
      required String name,
      required String photoUrl,
      required String token}) {
    try {
      return _store.collection('users').doc(userId).set({
        'userId': userId,
        'name': name,
        'photoUrl': photoUrl,
        'token': token,
      });
    } on Exception {
      rethrow;
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    notificationRepository.showNotification(
      title: message.notification?.title ?? 'Title',
      body: message.notification?.body ?? 'Body',
      id: message.messageId.hashCode,
      payload: jsonEncode(
        message.data,
      ),
    );
  }

  @override
  void listenToNotification() async {
    _onMessageReceived = FirebaseMessaging.onMessage.listen(null);
    _onNotificationOpenedApp =
        FirebaseMessaging.onMessageOpenedApp.listen(null);
    _onMessageReceived?.onData(
      (message) {
        notificationRepository.showNotification(
          title: message.notification?.title ?? 'Title',
          body: message.notification?.body ?? 'Body',
          id: message.messageId.hashCode,
          payload: jsonEncode(
            message.data,
          ),
        );
      },
    );

    _onNotificationOpenedApp?.onData(
      (message) {
        String notificationType = message.data['notificationType'];
        if (notificationType == 'chat') {
          log('Chat notification opened: ${message.data}');
          String chatId = message.data['chatId'];
          User userProfile = User(
            id: message.data['senderId'],
            name: message.data['senderName'],
            photoUrl: message.data['photoUrl'],
            email: '',
          );
          // appRouterService.appRouter.go(
          //   '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/$chatId',
          //   extra: userProfile,
          // );
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
