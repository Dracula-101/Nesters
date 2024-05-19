import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

abstract class ObxStorageRepository {
  Future<void> init();

  Future<void> saveReceipentUser(QuickChatUser user);

  Stream<List<QuickChatUser>> getChatUsersStream();
}
