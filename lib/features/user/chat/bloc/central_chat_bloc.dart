import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/chat/message.dart';
import 'package:nesters/domain/models/chat/message_type.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'central_chat_event.dart';
part 'central_chat_state.dart';
part 'central_chat_bloc.freezed.dart';

class CentralChatBloc extends Bloc<CentralChatEvent, CentralChatState> {
  CentralChatBloc() : super(CentralChatState.loading()) {
    on<CentralChatEvent>(_onCentralChatEvent);
  }

  final Map<String, ChatHandler> _chatHandlers = {};
  final Duration _fetchTimeDurationLimit = 4.day;
  StreamSubscription<List<QuickChatUser>>? _recipientUserStreamSubscription;
  late String userId;

  final AppLoggerService _logger = GetIt.I<AppLoggerService>();
  final LocalStorageRepository _localStorage =
      GetIt.I<LocalStorageRepository>();
  final ObxStorageRepository _obxStorageRepository =
      GetIt.I<ObxStorageRepository>();
  final RecipientUserRepository _recipientUserRepository =
      GetIt.I<RecipientUserRepository>();
  final RemoteChatRepository _chatRepository = GetIt.I<RemoteChatRepository>();

  Future<ChatHandler> getChatHandler(String chatId) async {
    if (_chatHandlers.containsKey(chatId)) {
      log('Chat Handler Exists');
      return _chatHandlers[chatId]!;
    } else {
      log('Chat Handler doesnt Exists');
      log(_chatHandlers.keys.toString());
      String recipientUserId =
          chatId.replaceAll(userId, '').replaceAll('_', '');
      return _createNewChatHandler(
        chatId,
        _obxStorageRepository.getQuickChatUser(chatId) ??
            (await _recipientUserRepository.getRecipientUser(recipientUserId))!,
        userId,
      );
    }
  }

  Future<void> _onCentralChatEvent(
    CentralChatEvent event,
    Emitter<CentralChatState> emit,
  ) async {
    await event.when(
      loadProfiles: (userId) async {
        this.userId = userId;
        await _loadProfiles(emit);
      },
      listenToProfiles: () async {
        await listenToLocalRecipientProfilesStream(emit);
      },
      forcedLoadProfiles: () async {
        await _forceLoadProfiles(emit);
      },
      loadChats: () async {
        await _loadChats();
      },
      sendMessage: (chatId, message) async {
        sendMessage(chatId, message);
      },
    );
  }

  FutureOr<void> _loadProfiles(Emitter<CentralChatState> emit) async {
    // Load Chat Profiles from local database
    try {
      List<ChatInfo> chatStates = [];
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
        //fetch data from remote if local is stale
        List<ChatHandler> chatHandlers = await _fetchRemoteRecipientUsers();
        for (ChatHandler chatHandler in chatHandlers) {
          addToChatHandlers(chatHandler);
        }
      }
      for (ChatHandler chatHandler in _chatHandlers.values) {
        chatStates.add(chatHandler.toChatState());
      }
      add(const CentralChatEvent.listenToProfiles());
      add(const CentralChatEvent.loadChats());
      emit(CentralChatState.loaded(chatStates));
    } on Exception catch (e) {
      emit(CentralChatState.error(e));
    }
  }

  Future<void> listenToLocalRecipientProfilesStream(
    Emitter<CentralChatState> emit,
  ) async {
    //listen to local database recipient profiles stream
    await emit.forEach<List<QuickChatUser>>(
      _obxStorageRepository.getChatUsersStream(),
      onData: (event) {
        if (event.isNotEmpty) {
          for (QuickChatUser user in event) {
            ChatHandler chatHandler = _createChatHandler(user, userId);
            addToChatHandlers(chatHandler);
          }
          return CentralChatState.loaded(
            _chatHandlers.values.map((e) => e.toChatState()).toList(),
          );
        }
        return CentralChatState.loaded(state.chatStates);
      },
    );
  }

  Future<void> _loadChats() async {
    for (ChatHandler chatHandler in _chatHandlers.values) {
      StreamSubscription<List<Message>> remoteChatSubscription =
          _chatRepository.getChatMessages(chatHandler.chatId).listen(null);
      chatHandler.addRemoteMessageListener(remoteChatSubscription);
    }
  }

  Future<void> _forceLoadProfiles(Emitter<CentralChatState> emit) async {
    try {
      emit(CentralChatState.loading());
      List<ChatInfo> chatStates = [];
      List<ChatHandler> chatHandlers = await _fetchRemoteRecipientUsers();
      replaceChatHandlers(chatHandlers);
      for (ChatHandler chatHandler in _chatHandlers.values) {
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

  void replaceChatHandlers(List<ChatHandler> chatHandlers) {
    _chatHandlers.clear();
    for (ChatHandler chatHandler in chatHandlers) {
      _chatHandlers.putIfAbsent(chatHandler.chatId, () {
        return chatHandler;
      });
    }
  }

  void addToChatHandlers(ChatHandler chatHandler) {
    bool chatExists = false;
    for (ChatHandler handler in _chatHandlers.values) {
      if (handler.recipientUser.userId == chatHandler.recipientUser.userId) {
        chatExists = true;
        break;
      }
    }
    if (!chatExists) {
      _chatHandlers.putIfAbsent(chatHandler.chatId, () {
        return chatHandler;
      });
    }
  }

  ChatHandler _createChatHandler(QuickChatUser recipientUser, String senderId) {
    return ChatHandler(
      chatId: recipientUser.chatId!,
      senderId: senderId,
      receiverId: recipientUser.userId!,
      recipientUser: recipientUser,
      localChatSubscription: _obxStorageRepository.getChatMessagesStream(
        recipientUser.chatId!,
      ),
    );
  }

  ChatHandler _createNewChatHandler(
    String chatId,
    QuickChatUser recipientUser,
    String senderId,
  ) {
    _chatHandlers.addAll({
      chatId: ChatHandler(
        chatId: chatId,
        senderId: senderId,
        receiverId: recipientUser.userId!,
        recipientUser: recipientUser,
        localChatSubscription: _obxStorageRepository.getChatMessagesStream(
          chatId,
        ),
      ),
    });
    return _chatHandlers[chatId]!;
  }

  Future<List<ChatHandler>> _fetchRemoteRecipientUsers() async {
    List<QuickChatUser> chatUsers = await _recipientUserRepository
        .getRecipientUsers(userId, (senderId, receiverId) {
      return _chatRepository.generateChatId(senderId, receiverId);
    });
    List<ChatHandler> chatHandlers = [];
    for (QuickChatUser user in chatUsers) {
      chatHandlers.add(_createChatHandler(user, userId));
    }
    unawaited(_obxStorageRepository.updateChatUser(chatUsers));
    unawaited(_localStorage.saveInt(LocalStorageKeys.lastSavedRecipientUsers,
        DateTime.now().millisecondsSinceEpoch));
    return chatHandlers;
  }

  Future<void> sendMessage(String chatId, Message message) async {
    String messageId = await _chatRepository.sendMessage(chatId, message);
    log(message.messageType.toString());
    _obxStorageRepository.saveMessage(
      chatId: chatId,
      messageId: messageId,
      content: message.content ?? '',
      senderId: message.senderId ?? '',
      type: message.messageType ?? ChatMessageType.TEXT,
      epochTime: message.epochTime.millisecondsSinceEpoch,
      timestamp: message.sentAt?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<void> close() {
    _recipientUserStreamSubscription?.cancel();
    for (ChatHandler chatHandler in _chatHandlers.values) {
      chatHandler.dispose();
    }
    return super.close();
  }
}

class ChatHandler {
  final String chatId;
  final String senderId;
  final String receiverId;
  final QuickChatUser recipientUser;
  StreamSubscription<List<Message>>? remoteChatSubscription;
  Stream<List<Message>> localChatSubscription;

  ChatHandler({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.recipientUser,
    this.remoteChatSubscription,
    required this.localChatSubscription,
  }) {
    localChatSubscription.listen((event) {
      _addMessages(event);
    });
  }

  StreamController<List<Message>> liveChatStreamController =
      StreamController.broadcast();
  Stream<List<Message>> get liveChatStream => liveChatStreamController.stream;
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
      localChatSubscription: localChatSubscription,
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
