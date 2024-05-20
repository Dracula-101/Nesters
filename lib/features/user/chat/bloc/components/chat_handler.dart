import 'dart:developer';

import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'dart:async';

import 'package:nesters/features/user/chat/bloc/central_chat_bloc.dart';

class ChatHandler {
  final String chatId;
  final String senderId;
  final String receiverId;
  final QuickChatUser recipientUser;
  StreamSubscription<List<Message>>? remoteChatSubscription;

  ChatHandler({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.recipientUser,
    this.remoteChatSubscription,
  });

  StreamController<List<Message>> liveChatStreamController =
      StreamController.broadcast();
  Stream<List<Message>> get liveChatStream =>
      liveChatStreamController.stream.asBroadcastStream();
  List<Message> liveChatMessages = [];

  void addRemoteMessageListener(
      StreamSubscription<List<Message>> remoteChatSubscription) {
    this.remoteChatSubscription = remoteChatSubscription;
    remoteChatSubscription.onData((data) {
      _addMessages(data);
    });
  }

  void _addMessages(List<Message> messages) {
    if (messages.isEmpty) return;
    DateTime latestEpochTime = messages.last.epochTime;
    liveChatMessages.clear();
    for (Message message in messages) {
      if (message.epochTime.isAfter(latestEpochTime)) {
        liveChatMessages.add(message);
      }
    }
    // sort descending by epoch time
    liveChatMessages.sort((a, b) => b.epochTime.compareTo(a.epochTime));
    liveChatStreamController.add(liveChatMessages);
  }

  void dispose() {
    remoteChatSubscription?.cancel();
  }

  @override
  String toString() {
    return 'ChatHandler{chatId: $chatId, senderId: $senderId, receiverId: $receiverId, recipientUser: $recipientUser}';
  }

  ChatHandler copyWith({
    String? chatId,
    String? senderId,
    String? receiverId,
    QuickChatUser? recipientUser,
  }) {
    return ChatHandler(
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      recipientUser: recipientUser ?? this.recipientUser,
      remoteChatSubscription: remoteChatSubscription,
    );
  }

  ChatInfo toChatState() {
    return ChatInfo(
      chatId: chatId,
      recipientUser: recipientUser,
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}
