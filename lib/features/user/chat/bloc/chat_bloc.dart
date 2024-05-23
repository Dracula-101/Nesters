import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';
import 'package:nesters/features/user/chat/bloc/controllers/chat_controller.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatController controller;
  ChatBloc({
    required this.controller,
  }) : super(ChatState.initial()) {
    on<ChatEvent>(_onChatEvent);
  }

  // Repositories
  final AppLoggerService _loggerService = GetIt.I<AppLoggerService>();
  final MediaRepository _mediaRepository = GetIt.I<MediaRepository>();
  final LocalStorageRepository _localStorageRepository =
      GetIt.I<LocalStorageRepository>();
  final ObxStorageRepository _obxStorageRepository =
      GetIt.I<ObxStorageRepository>();
  final RecipientUserRepository _recipientQuickUserRepository =
      GetIt.I<RecipientUserRepository>();
  final RemoteChatRepository _chatRepository = GetIt.I<RemoteChatRepository>();
  final UserStatusRepository _userStatusRepository =
      GetIt.I<UserStatusRepository>();

  // Streams
  Stream<List<Message>> get chatMessages =>
      controller.liveChatStream.asBroadcastStream();

  final StreamController<UserStatus> _userStatusController =
      StreamController.broadcast();
  Stream<UserStatus>? get userStatus =>
      _userStatusController.stream.asBroadcastStream();

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
    emit(
      state.copyWith(
          isLoading: true, senderId: senderId, receiverId: receiverId),
    );
    try {
      log("ChatId: ${controller.chatId}");
      bool chatExists =
          _localStorageRepository.getBool(controller.chatId) ?? false;

      // if (!chatExists) {
      //   bool chatExistsRemote =
      //       await _chatRepository.doesChatExist(controller.chatId);
      //   if (!chatExistsRemote) {
      //     await _chatRepository.createChat(
      //       controller.chatId,
      //       senderId: senderId,
      //       receiverId: receiverId,
      //     );
      //     unawaited(saveReceipentDetails());
      //   }
      // }
      emit(
        state.copyWith(
            doesChatExist: true, chatId: controller.chatId, isLoading: false),
      );
      _listenUserStatus(controller.chatId, emit);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e,
        ),
      );
    }
  }

  Future<void> _listenUserStatus(String chatId, Emitter<ChatState> emit) async {
    await _userStatusSubscription?.cancel();
    _userStatusSubscription = _userStatusRepository
        .getUserStatus(state.receiverId!)
        .asBroadcastStream()
        .listen(
          (event) => _userStatusController.add(
            event ?? UserStatus.empty(state.senderId!),
          ),
        );
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
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  Future<void> _sendDocument(
      DocumentSource source, String senderId, Emitter<ChatState> emit) async {
    try {
      File? file = await (source == DocumentSource.CAMERA
          ? _mediaRepository.getImageFromCamera()
          : _mediaRepository.getImageFromGallery());
      if (file == null) return;
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
          _sendMessage(message, emit, attachmentMessage: true);
          emit(state.copyWith(uploadTask: null));
          return;
        } else if (task.progress > 0) {
          emit(state.copyWith(uploadTask: {source: task}));
        }
      }
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  Future<void> _downloadDocument(
      String url, VoidCallback onComplete, Emitter<ChatState> emit) async {
    try {
      String? message = await _chatRepository.downloadDocument(url);
      if (message != null) {
        onComplete();
      } else {
        emit(state.copyWith(error: Exception('Failed to download document')));
      }
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  Future<void> saveReceipentDetails() async {
    //store details in local database
    try {
      QuickChatUser? receiptUser = await _recipientQuickUserRepository
          .getRecipientUser(state.receiverId!);
      receiptUser = receiptUser?.copyWith(
        chatId: state.chatId,
      );
      log("Recipient User: $receiptUser");
      if (receiptUser != null) {
        log('Saving recipient user: $receiptUser');
        await _obxStorageRepository.saveRecipientUser(receiptUser);
      }
      await _localStorageRepository.saveBool(state.chatId!, true);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _cancelChatSubscription();
    return super.close();
  }
}
