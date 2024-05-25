import 'dart:async';
import 'dart:developer';

import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/features/user/chat/bloc/central_chat_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'message_controller.dart';

class ChatController {
  final String chatId;
  final String senderId;
  final String receiverId;
  final QuickChatUser recipientUser;
  final Subject<List<Message>> localChatSubscription;
  final Subject<List<Message>> Function(String? epochTime) remoteChatStream;
  final ObxStorageRepository storage;
  ChatController({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.recipientUser,
    required this.localChatSubscription,
    required this.remoteChatStream,
    required this.storage,
  }) {
    _intializeController();
    _listenToLocalMessages();
  }

  StreamSubscription<List<Message>>? _localStreamSubscription;
  StreamSubscription<List<Message>>? _newMessageSubscription;

  late MessageController _messageController;
  Stream<List<Message>> get liveChatStream => _messageController.liveChatStream
      .mapNotNull((messages) => messages.reversed.toList());
  Stream<Message?> get latestMessageStream =>
      _messageController.latestMessageStream;

  void _intializeController() {
    _messageController = MessageController(
      intialMessages: storage.getChatMessages(chatId),
      getRemoteStream: remoteChatStream,
    );
    _newMessageSubscription = _messageController.newMessageStream.listen(null);
    _newMessageSubscription?.onData(_onNewLocalMessage);
  }

  void _listenToLocalMessages() {
    _localStreamSubscription =
        localChatSubscription.listen(_messageController.addMessages);
  }

  void _onNewLocalMessage(List<Message> messages) {
    for (final message in messages) {
      storage.saveMessage(chatId, message);
    }
  }

  // void addMessage(Message message) {
  //   _messageController.addMessage(message);
  // }

  Future<void> closeChat() async {
    await _localStreamSubscription?.cancel();
    await _newMessageSubscription?.cancel();
    await _messageController.close();
  }

  ChatInfo toChatInfo() {
    return ChatInfo(
      chatId: chatId,
      recipientUser: recipientUser,
      receiverId: receiverId,
      senderId: senderId,
    );
  }
}
