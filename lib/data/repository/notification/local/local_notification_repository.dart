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
  GetIt.I<LocalNotificationRepository>()
      .onDidReceiveNotificationResponse(details);
}

class LocalNotificationRepository {
  LocalNotificationRepository({required this.appRouterService});

  final AppRouterService appRouterService;
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
    NotificationResponse details,
  ) async {
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
          accessToken: '',
        );
        // get current route path
        final currentRoute =
            appRouterService.appRouter.routeInformationProvider.value.uri.path;
        // check if the current route is not the chat screen
        if (!currentRoute.contains(chatId)) {
          appRouterService.appRouter.push(
            '${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/$chatId',
            extra: userProfile,
          );
        }
      }
    }
  }

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
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
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
    required String payload,
  }) async {
    Map<String, dynamic> message = json.decode(payload);
    String notificationType = message['notificationType'];
    NotificationType type = notificationType == 'chat'
        ? NotificationType.chat
        : NotificationType.request;
    switch (type) {
      case NotificationType.chat:
        await _showChatNotification(
          title: title,
          body: body,
          payload: message,
        );
        break;
      case NotificationType.request:
        await _showRequestNotification(
          title: title,
          body: body,
          payload: message,
        );
        break;
    }
  }

  Future<AndroidNotificationDetails> _chatNotificationChannelDetails(
    int id,
    String title,
    Map<String, dynamic> payload,
    String body,
  ) async {
    MessagingStyleInformation? messagingStyle =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .getActiveNotificationMessagingStyle(id);
    AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(
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
            await base64encodedImage(payload['photoUrl']),
          ),
        ),
        conversationTitle: title,
        groupConversation: false,
        messages: [
          ...messagingStyle?.messages ?? [],
          Message(
            title,
            payload.containsKey('time')
                ? DateTime.fromMillisecondsSinceEpoch(
                    int.parse(payload['time']),
                  )
                : DateTime.now(),
            null,
          )
        ],
      ),
      category: AndroidNotificationCategory.message,
    );
    return notificationDetails;
  }

  AndroidNotificationDetails _requestNotificationChannelDetails(
    int id,
    String title,
    Map<String, dynamic> payload,
    String body,
  ) {
    return const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      styleInformation: DefaultStyleInformation(true, true),
      category: AndroidNotificationCategory.event,
    );
  }

  int generateChatMessageId(Map<String, dynamic> payload) {
    String senderId = payload['senderId'];
    String notificationId =
        senderId.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 3);
    return int.tryParse(notificationId) ?? 0;
  }

  Future<void> _showChatNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    int messageId = generateChatMessageId(payload);
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        await _chatNotificationChannelDetails(messageId, title, payload, body);
    String currentPath =
        appRouterService.appRouter.routeInformationProvider.value.uri.path;
    String chatId = payload['chatId'];
    log("Received Notification -> Current Path: $currentPath, Chat Id: $chatId");
    if (!currentPath.contains(chatId)) {
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
        messageId,
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode(payload),
      );
    }
  }

  Future<void> _showRequestNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        _requestNotificationChannelDetails(0, title, payload, body);
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(payload),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

enum NotificationType { chat, request }
