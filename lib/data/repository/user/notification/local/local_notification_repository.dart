import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/painting/image_decoder.dart' as image_decoder;

class LocalNotificationRepository {
  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings();
  static const String _channelId = 'nester_notification_channel';
  static const String _channelName = 'Nester Notification Channel';
  static const String _channelDescription = 'Nester Notification Channel';
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
    );
    _initializeNotificationChannel();
  }

  void _initializeNotificationChannel() {
    if (Platform.isAndroid) {
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(channel);
    }
  }

  Future<String> _base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required int id,
    required String payload,
  }) async {
    String photoUrl = json.decode(payload)['photoUrl'];
    log('Photo Url: $photoUrl');
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: MessagingStyleInformation(
        Person(
          name: title,
          icon: ByteArrayAndroidIcon.fromBase64String(
            await _base64encodedImage(photoUrl),
          ),
        ),
        conversationTitle: title,
        groupConversation: false,
        htmlFormatContent: true,
        htmlFormatTitle: true,
        messages: [
          Message(
            body,
            DateTime.now(),
            null,
          ),
        ],
      ),
      category: AndroidNotificationCategory.message,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      null,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
