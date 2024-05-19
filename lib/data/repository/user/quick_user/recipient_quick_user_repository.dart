import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';

abstract class RecipientUserRepository {
  Future<QuickChatUser?> getChatQuickUser(String userId);
}
