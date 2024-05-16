import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/domain/models/chat_message.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState.initial()) {
    on<ChatEvent>(_onChatEvent);
  }

  final RemoteChatRepository _chatRepository = GetIt.I<RemoteChatRepository>();
  final StreamController<List<Message>> _chatMessages = StreamController();
  StreamSubscription? _chatSubscription;
  Stream<List<Message>> get chatMessages =>
      _chatMessages.stream.asBroadcastStream();

  Future<void> _onChatEvent(ChatEvent event, Emitter<ChatState> emit) async {
    await event.when(
      loadChats: (chatId) {
        _listenChats(chatId, emit);
      },
      checkChat: (senderId, receiverId) async {
        await _checkChat(senderId, receiverId, emit);
      },
      sendMessage: (message) async {
        await _sendMessage(message, emit);
      },
      disposeChatSubscription: () {
        disposeChatSubscription();
      },
    );
  }

  Future<void> _checkChat(
      String senderId, String receiverId, Emitter<ChatState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String chatId = _chatRepository.generateChatId(senderId, receiverId);
      bool chatExists = await _chatRepository.doesChatExist(chatId);
      if (!chatExists) {
        await _chatRepository.createChat(chatId,
            senderId: senderId, receiverId: receiverId);
      }
      emit(state.copyWith(
          doesChatExist: true, chatId: chatId, isLoading: false));
      _listenChats(chatId, emit);
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  void _listenChats(String chatId, Emitter<ChatState> emit) {
    _chatSubscription = _chatRepository
        .getChatMessages(chatId)
        .asBroadcastStream()
        .listen((event) {
      _chatMessages.add(event);
      GetIt.I<AppLoggerService>().info('Chat Messages: $event');
    });
  }

  void disposeChatSubscription() {
    _chatSubscription?.cancel();
  }

  Future<void> _sendMessage(Message message, Emitter<ChatState> emit) async {
    // emit(state.copyWith(isLoading: true));
    try {
      await _chatRepository.sendMessage(state.chatId!, message);
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }
}
