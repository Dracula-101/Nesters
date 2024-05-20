import 'dart:async';

import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';

abstract class ObxStorageRepository {
  // Open and Closing the database
  Future<void> init();
  void close();
  Future<void> reset();

  Stream<List<QuickChatUser>> getChatUsersStream();
  List<QuickChatUser> getChatUserProfiles();
  QuickChatUser? getQuickChatUser(String chatId);
  Future<void> updateChatUser(List<QuickChatUser> users);
  Future<void> saveRecipientUser(QuickChatUser user);

  void saveMessage({
    required String chatId,
    required String messageId,
    required String content,
    required String senderId,
    required ChatMessageType type,
    required int epochTime,
    required DateTime timestamp,
  });

  Stream<List<Message>> getChatMessagesStream(String chatId);
  List<Message> getChatMessages(String chatId);
}
