import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/data/repository/notification/local/local_notification_repository.dart';

abstract class RemoteNotificationRepository {
  RemoteNotificationRepository({
    required this.notificationRepository,
    required this.appRouterService,
  });

  final LocalNotificationRepository notificationRepository;
  final AppRouterService appRouterService;

  Future<bool> init();
  Future<String> getToken();
  Future<void> saveData({
    required String userId,
    required String fullName,
    required String photoUrl,
    required String token,
  });
  void listenToTokenChanges(String userId);
  void listenToNotification();
  void removeNotificationListener();
}
