import 'dart:io';

import 'package:nesters/domain/models/chat_message.dart';

abstract class RemoteChatRepository {
  String generateChatId(String senderId, String receiverId);
  Future<List<Message>> fetchChatMessages(String chatId);
  Stream<List<Message>> getChatMessages(String chatId);
  Future<void> sendMessage(String chatId, Message message);
  Future<bool> doesChatExist(String chatId);
  Future<void> createChat(String chatId,
      {required String senderId, required String receiverId});
  Future<String?> uploadImageToChat(
      {required File file, required String chatID});
}
