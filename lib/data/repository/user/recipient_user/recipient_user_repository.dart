import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

abstract class RecipientUserRepository {
  Future<QuickChatUser?> getRecipientUser(String userId);
  Future<List<QuickChatUser>> getRecipientUsers(String currentUserId);
}
