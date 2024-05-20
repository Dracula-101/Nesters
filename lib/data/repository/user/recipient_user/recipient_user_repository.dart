import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

abstract class RecipientUserRepository {
  Future<QuickChatUser?> getRecipientUser(String userId);
  Future<List<QuickChatUser>> getRecipientUsers(
    String currentUserId,
    Function(String, String) generateChatId,
  );
  Stream<List<QuickChatUser>> getRecipientUsersStream(
    String userId,
    Function(String, String) generateChatId,
  );
}
