import 'package:nesters/data/repository/user/notification/local/local_notification_repository.dart';

abstract class RemoteNotificationRepository {
  RemoteNotificationRepository({
    required this.notificationRepository,
  });

  final LocalNotificationRepository notificationRepository;

  Future<bool> init();
  Future<String> getToken();
  Future<void> saveData({
    required String userId,
    required String name,
    required String photoUrl,
    required String token,
  });
  void listenToNotification();
}
