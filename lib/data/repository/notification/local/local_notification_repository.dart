import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/user/user.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotification(NotificationResponse details) {
  log('onDidReceiveBackgroundNotification: ${details.payload}');
}

class LocalNotificationRepository {
  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      const DarwinInitializationSettings();
  static const String _channelId = 'nester_notification_channel';
  static const String _channelName = 'Nester Notification Channel';
  static const String _channelDescription = 'Nester Chat Notifications';
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  Future<void> onDidReceiveNotificationResponse(
      NotificationResponse details) async {
    log('Recieved Notification -> navigating to chat screen: ${details.payload}');
    if (details.payload != null) {
      final Map<String, dynamic> message = json.decode(details.payload!);
      String notificationType = message['notificationType'];
      if (notificationType == 'chat') {
        String chatId = message['chatId'];
        User userProfile = User(
          id: message['senderId'],
          fullName: message['senderName'],
          photoUrl: message['photoUrl'],
          email: '',
        );
        GetIt.I<AppRouterService>().appRouter.push(
              '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/$chatId',
              extra: userProfile,
            );
      }
    }
  }

  AppRouterService appRouterService;
  LocalNotificationRepository({required this.appRouterService});

  Future<void> init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotification,
    );
    await _initializeNotificationChannel();
  }

  Future<void> _initializeNotificationChannel() async {
    if (Platform.isAndroid) {
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        showBadge: true,
        playSound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(channel);
    }
  }

  Future<String> base64encodedImage(String url) async {
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
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
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

  Future<AndroidNotificationDetails> _chatNotificationChannelDetails(
      String title, String payload, String body) async {
    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      styleInformation: MessagingStyleInformation(
        Person(
          name: title,
          icon: ByteArrayAndroidIcon.fromBase64String(
            await base64encodedImage(
              json.decode(payload)['photoUrl'],
            ),
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
  }

  Future<void> showChatNotification(
      {required String title,
      required String body,
      required int id,
      required String payload}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        await _chatNotificationChannelDetails(title, payload, body);
    String currentPath =
        appRouterService.appRouter.routeInformationProvider.value.uri.path;
    String chatId = json.decode(payload)['chatId'];
    log("Received Notification -> Current Path: $currentPath, Chat Id: $chatId");
    if (!currentPath.contains(chatId)) {
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
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
