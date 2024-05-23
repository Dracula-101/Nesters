import 'dart:async';

import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:rxdart/rxdart.dart';

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

  void saveMessage(String chatId, Message message);

  Stream<List<Message>> getChatMessagesStream(String chatId);
  Subject<List<Message>> getChatMessagesSubject(String chatId);
  List<Message> getChatMessages(String chatId);
}
