import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/data/repository/user/chat/remote_chat_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/chat/bloc/controllers/chat_controller.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatController controller;
  ChatBloc({
    required this.controller,
  }) : super(ChatState()) {
    on<ChatEvent>(_onChatEvent);
  }

  // Repositories
  final _loggerService = GetIt.I<AppLogger>();
  final _mediaRepository = GetIt.I<MediaRepository>();
  final _localStorageRepository = GetIt.I<LocalStorageRepository>();
  final _obxStorageRepository = GetIt.I<ObxStorageRepository>();
  final _recipientQuickUserRepository = GetIt.I<RecipientUserRepository>();
  final _chatRepository = GetIt.I<RemoteChatRepository>();
  final _userStatusRepository = GetIt.I<UserStatusRepository>();

  // Streams
  Stream<List<Message>> get chatMessages =>
      controller.liveChatStream.asBroadcastStream().distinctUnique();

  final StreamController<UserStatus> _userStatusController =
      StreamController.broadcast();
  Stream<UserStatus>? get userStatus =>
      _userStatusController.stream.asBroadcastStream().distinctUnique();

  StreamSubscription? _userStatusSubscription;

  List<Message> getInitialMessages() {
    return _obxStorageRepository.getChatMessages(controller.chatId);
  }

  Future<void> _onChatEvent(ChatEvent event, Emitter<ChatState> emit) async {
    await event.when(
      loadChats: (chatId) async {
        await _listenUserStatus(chatId, emit);
      },
      checkChat: (senderId, receiverId) async {
        await _checkChat(senderId, receiverId, emit);
      },
      sendMessage: (message) async {
        await _sendMessage(message, emit);
      },
      closeChat: () {
        _cancelChatSubscription();
      },
      sendDocument: (source, senderId) async {
        await _sendDocument(source, senderId, emit);
      },
      downloadDocument: (url, onComplete) async {
        await _downloadDocument(url, onComplete, emit);
      },
    );
  }

  Future<void> _checkChat(
      String senderId, String receiverId, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      senderId: senderId,
      receiverId: receiverId,
      chatState: state.chatState?.loading(),
    ));
    try {
      log("ChatId: ${controller.chatId}");

      emit(
        state.copyWith(
            doesChatExist: true,
            chatId: controller.chatId,
            chatState: state.chatState?.success()),
      );
      controller.clearNewMessages();
      _listenUserStatus(controller.chatId, emit);
    } on AppException catch (e) {
      emit(
        state.copyWith(
          doesChatExist: false,
          chatState: state.chatState?.failure(e),
        ),
      );
    }
  }

  Future<void> _listenUserStatus(String chatId, Emitter<ChatState> emit) async {
    await _userStatusSubscription?.cancel();
    _userStatusSubscription =
        _userStatusRepository.getUserStatus(state.receiverId!).listen(null);
    _userStatusSubscription?.onData((event) {
      _userStatusController.add(event);
    });
  }

  Future<void> _cancelChatSubscription() async {
    _loggerService.info('Cancelling chat subscription');
    if (_userStatusSubscription != null) {
      _userStatusSubscription!.cancel();
      _userStatusSubscription = null;
    }
  }

  Future<void> _sendMessage(Message message, Emitter<ChatState> emit,
      {bool attachmentMessage = false}) async {
    // emit(state.copyWith(isLoading: true));
    try {
      String messageId =
          await _chatRepository.sendMessage(state.chatId!, message);
      _loggerService.log('Message sent: $messageId');
    } on AppException catch (e) {
      emit(state.copyWith(chatState: state.chatState?.failure(e)));
    }
  }

  Future<void> _sendDocument(
      DocumentSource source, String senderId, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(isLoadingMedia: true));
      File? file = await (source == DocumentSource.CAMERA
          ? _mediaRepository.getImageFromCamera()
          : _mediaRepository.getImageFromGallery());
      if (file == null) {
        emit(state.copyWith(isLoadingMedia: false));
        return;
      }
      Stream<DocumentUploadTask> uploadTask = _chatRepository.uploadDocument(
        file: file,
        chatID: state.chatId!,
      );
      emit(state.copyWith(
          uploadTask: {source: DocumentUploadTask(isPreLoading: true)}));
      await for (DocumentUploadTask task in uploadTask) {
        if (task.isComplete) {
          Message message = Message(
            id: "",
            senderId: senderId,
            messageType: ChatMessageType.IMAGE,
            content: task.url,
            sentAt: Timestamp.now(),
            epochTime: DateTime.now(),
          );
          await _sendMessage(message, emit, attachmentMessage: true);
          emit(state.copyWith(isLoadingMedia: false));
          break;
        } else if (task.progress > 0 && !task.isComplete) {
          emit(state.copyWith(uploadTask: {source: task}));
        }
      }
      emit(state.copyWith(uploadTask: null));
    } on AppException catch (e) {
      emit(state.copyWith(chatState: state.chatState?.failure(e)));
    }
  }

  Future<void> _downloadDocument(
      String url, VoidCallback onComplete, Emitter<ChatState> emit) async {
    try {
      String? message = await _chatRepository.downloadDocument(url);
      if (message != null) {
        onComplete();
      } else {
        return;
      }
    } on AppException catch (e) {
      emit(state.copyWith(chatState: state.chatState?.failure(e)));
    }
  }

  @override
  Future<void> close() async {
    controller.clearNewMessages();
    await _cancelChatSubscription();
    return super.close();
  }
}
