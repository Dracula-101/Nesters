import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'central_chat_event.dart';
part 'central_chat_state.dart';
part 'central_chat_bloc.freezed.dart';

class CentralChatBloc extends Bloc<CentralChatEvent, CentralChatState> {
  CentralChatBloc() : super(CentralChatState.loading()) {
    on<CentralChatEvent>(_onCentralChatEvent);
  }

  late String userId;
  final ObxStorageRepository _obxStorageRepository =
      GetIt.I<ObxStorageRepository>();
  final LocalStorageRepository _localStorage =
      GetIt.I<LocalStorageRepository>();
  final RecipientUserRepository _recipientUserRepository =
      GetIt.I<RecipientUserRepository>();
  final AppLoggerService _logger = GetIt.I<AppLoggerService>();
  List<ChatHandler> _chatHandlers = [];
  final Duration _fetchTimeDurationLimit = 4.day;

  Future<void> _onCentralChatEvent(
    CentralChatEvent event,
    Emitter<CentralChatState> emit,
  ) async {
    await event.when(
      loadProfiles: (userId) async {
        this.userId = userId;
        await _loadProfiles(emit);
      },
      forcedLoadProfiles: () async {
        await _forceLoadProfiles(emit);
      },
      loadChats: () {},
    );
  }

  FutureOr<void> _loadProfiles(Emitter<CentralChatState> emit) async {
    try {
      List<ChatState> chatStates = [];
      // Get Last Remote Users Fetched Time
      DateTime lastFetchedRemoteUsers = DateTime.fromMillisecondsSinceEpoch(
        _localStorage.getInt(LocalStorageKeys.lastSavedRecipientUsers) ?? 0,
      );
      // Fetch Local Recipient Profiles
      bool isChatsAvailable = _checkLocalRecipientProfile();
      bool isFetchTimeLimitExceeded =
          DateTime.now().difference(lastFetchedRemoteUsers) >
              _fetchTimeDurationLimit;
      if (isFetchTimeLimitExceeded && !isChatsAvailable) {
        List<ChatHandler> chatHandlers = await _fetchRemoteRecipientUsers();
        for (ChatHandler chatHandler in chatHandlers) {
          if (!_chatHandlers.contains(chatHandler)) {
            _chatHandlers.add(chatHandler);
          }
        }
      }
      for (ChatHandler chatHandler in _chatHandlers) {
        chatStates.add(chatHandler.toChatState());
      }
      emit(CentralChatState.loaded(chatStates));
    } on Exception catch (e) {
      emit(CentralChatState.error(e));
    }
  }

  Future<void> _forceLoadProfiles(Emitter<CentralChatState> emit) async {
    try {
      emit(CentralChatState.loading());
      List<ChatState> chatStates = [];
      _chatHandlers = await _fetchRemoteRecipientUsers();
      for (ChatHandler chatHandler in _chatHandlers) {
        chatStates.add(chatHandler.toChatState());
      }
      emit(CentralChatState.loaded(chatStates));
    } on Exception catch (e) {
      emit(CentralChatState.error(e));
    }
  }

  bool _checkLocalRecipientProfile() {
    List<QuickChatUser> chatUsers = _obxStorageRepository.getChatUserProfiles();
    if (chatUsers.isNotEmpty) {
      for (QuickChatUser user in chatUsers) {
        ChatHandler chatHandler = _createChatHandler(user, userId);
        addToChatHandlers(chatHandler);
      }
    }
    _logger.log('Chat Users: $chatUsers');
    return chatUsers.isNotEmpty;
  }

  void addToChatHandlers(ChatHandler chatHandler) {
    bool chatExists = false;
    for (ChatHandler handler in _chatHandlers) {
      if (handler.recipientUser.userId == chatHandler.recipientUser.userId) {
        chatExists = true;
        break;
      }
    }
    if (!chatExists) {
      _chatHandlers.add(chatHandler);
    }
  }

  ChatHandler _createChatHandler(QuickChatUser recipientUser, String senderId) {
    return ChatHandler(
      chatId: recipientUser.chatId!,
      senderId: senderId,
      receiverId: recipientUser.userId!,
      recipientUser: recipientUser,
    );
  }

  Future<List<ChatHandler>> _fetchRemoteRecipientUsers() async {
    List<QuickChatUser> chatUsers =
        await _recipientUserRepository.getRecipientUsers(userId);
    List<ChatHandler> chatHandlers = [];
    for (QuickChatUser user in chatUsers) {
      chatHandlers.add(_createChatHandler(user, userId));
    }
    unawaited(_obxStorageRepository.updateChatUser(chatUsers));
    return chatHandlers;
  }
}

class ChatHandler {
  final String chatId;
  final String senderId;
  final String receiverId;
  final QuickChatUser recipientUser;
  StreamSubscription? remoteChatSubscription;

  ChatHandler({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.recipientUser,
    this.remoteChatSubscription,
  });

  final StreamController<List<Message>> _chatMessages =
      StreamController.broadcast();
  Stream<List<Message>> get chatMessages =>
      _chatMessages.stream.asBroadcastStream();

  void addMessageListener(StreamSubscription remoteChatSubscription) {
    this.remoteChatSubscription = remoteChatSubscription;
    remoteChatSubscription.onData((data) {
      _chatMessages.add(data);
    });
  }

  void dispose() {
    _chatMessages.close();
    remoteChatSubscription?.cancel();
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

  ChatState toChatState() {
    return ChatState(
      chatId: chatId,
      recipientUser: recipientUser,
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}
