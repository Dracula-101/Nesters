import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'chat_event.dart';
part 'chat_state.dart';
part 'chat_bloc.freezed.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final String chatId;
  final Stream<List<Message>> Function() onListenChats;
  ChatBloc({
    required this.chatId,
    required this.onListenChats,
  }) : super(ChatState.initial()) {
    on<ChatEvent>(_onChatEvent);
  }

  // Repositories
  final AppLoggerService _loggerService = GetIt.I<AppLoggerService>();
  final MediaRepository _mediaRepository = GetIt.I<MediaRepository>();
  final ObxStorageRepository _obxStorageRepository =
      GetIt.I<ObxStorageRepository>();
  final RecipientUserRepository _recipientQuickUserRepository =
      GetIt.I<RecipientUserRepository>();
  final RemoteChatRepository _chatRepository = GetIt.I<RemoteChatRepository>();
  final UserStatusRepository _userStatusRepository =
      GetIt.I<UserStatusRepository>();

  // Streams
  final StreamController<List<Message>> _chatMessages =
      StreamController.broadcast();
  Stream<List<Message>> get chatMessages =>
      _chatMessages.stream.asBroadcastStream();

  final StreamController<UserStatus> _userStatusController =
      StreamController.broadcast();
  Stream<UserStatus>? get userStatus =>
      _userStatusController.stream.asBroadcastStream();

  StreamSubscription? _chatSubscription,
      _userStatusSubscription,
      _localChatSubscription;

  List<Message> getInitialMessages() {
    return _obxStorageRepository.getChatMessages(chatId);
  }

  Future<void> _onChatEvent(ChatEvent event, Emitter<ChatState> emit) async {
    await event.when(
      loadChats: (chatId) async {
        await _listenChats(chatId, emit);
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
      log("ChatId: $chatId");
      bool chatExists = await _chatRepository.doesChatExist(chatId);
      if (!chatExists) {
        await _chatRepository.createChat(
          chatId,
          senderId: senderId,
          receiverId: receiverId,
        );
        unawaited(saveReceipentDetails());
      }
      emit(
        state.copyWith(doesChatExist: true, chatId: chatId, isLoading: false),
      );
      _listenChats(chatId, emit);
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e,
        ),
      );
    }
  }

  Future<void> _listenChats(String chatId, Emitter<ChatState> emit) async {
    listenOnLocalMessages();
    await _chatSubscription?.cancel(); // Cancel any existing subscription
    _chatSubscription = onListenChats().listen(
      null,
      onError: (e) {
        emit(
          state.copyWith(
            error: e,
          ),
        );
      },
    );
    _chatSubscription?.onData((data) {
      _saveToLocalDatabase(data);
      addChatMessage(data);
    });
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

  void _saveToLocalDatabase(List<Message> event) {
    _obxStorageRepository.saveMessage(
      chatId: chatId,
      messageId: event.last.id,
      content: event.last.content ?? '',
      senderId: event.last.senderId ?? '',
      type: event.last.messageType ?? ChatMessageType.TEXT,
      epochTime: event.last.epochTime.millisecondsSinceEpoch,
      timestamp: event.last.sentAt?.toDate() ?? DateTime.now(),
    );
  }

  void listenOnLocalMessages() {
    _localChatSubscription =
        _obxStorageRepository.getChatMessagesStream(chatId).listen((event) {
      addChatMessage(event);
    });
  }

  void addChatMessage(List<Message> messages) {
    _chatMessages.add(messages);
  }

  Future<void> _cancelChatSubscription() async {
    _loggerService.info('Cancelling chat subscription');
    if (_chatSubscription != null) {
      _chatSubscription!.cancel();
      _chatSubscription = null;
    }
    if (_userStatusSubscription != null) {
      _userStatusSubscription!.cancel();
      _userStatusSubscription = null;
    }
    await _chatMessages.close();
  }

  Future<void> _sendMessage(Message message, Emitter<ChatState> emit) async {
    // emit(state.copyWith(isLoading: true));
    try {
      String messageId =
          await _chatRepository.sendMessage(state.chatId!, message);
      _loggerService.log('Message sent: $messageId');
      _obxStorageRepository.saveMessage(
        chatId: chatId,
        messageId: messageId,
        content: message.content ?? '',
        senderId: message.senderId ?? '',
        type: message.messageType ?? ChatMessageType.TEXT,
        epochTime: message.epochTime.millisecondsSinceEpoch,
        timestamp: message.sentAt?.toDate() ?? DateTime.now(),
      );
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
          String messageId =
              await _chatRepository.sendMessage(state.chatId!, message);
          message = message.copyWith(id: messageId);
          _sendMessage(message, emit);
          emit(state.copyWith(uploadTask: null));
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
