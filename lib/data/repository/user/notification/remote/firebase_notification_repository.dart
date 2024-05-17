import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nesters/data/repository/user/notification/local/local_notification_repository.dart';
import 'package:nesters/data/repository/user/notification/remote/remote_notification_repository.dart';

class FirebaseNotificationRepository extends RemoteNotificationRepository {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  FirebaseNotificationRepository({
    required LocalNotificationRepository notificationRepository,
  }) : super(notificationRepository: notificationRepository);

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
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } on Exception {
      rethrow;
    }
  }

  @override
  void listenToNotification() {
    FirebaseMessaging.onBackgroundMessage(
        (message) => _firebaseMessagingBackgroundHandler(message));
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
      payload: jsonEncode(message.data),
    );
  }
}
