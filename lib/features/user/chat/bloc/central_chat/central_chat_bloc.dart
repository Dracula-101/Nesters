import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/object_box/repository/obx_storage_repository.dart';
import 'package:nesters/data/repository/user/chat/user_chat_repository.dart';
import 'package:nesters/data/repository/user/recipient_user/recipient_user_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/user/status/status.dart';
import 'package:nesters/features/user/chat/bloc/controllers/chat_controller.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'central_chat_event.dart';
part 'central_chat_state.dart';

class CentralChatBloc extends Bloc<CentralChatEvent, CentralChatState> {
  CentralChatBloc() : super(const CentralChatState()) {
    on<CentralChatEvent>(_onCentralChatEvent);
  }

  final Map<String, ChatController> _chatControllers = {};
  StreamSubscription<List<QuickChatUser>>? _recipientUserStreamSubscription;
  late String userId;

  final _logger = GetIt.I<AppLogger>();
  final _localStorage = GetIt.I<LocalStorageRepository>();
  final _obxStorageRepository = GetIt.I<ObxStorageRepository>();
  final _recipientUserRepository = GetIt.I<RecipientUserRepository>();
  final _chatRepository = GetIt.I<RemoteChatRepository>();
  final _appSecretsRepository = GetIt.I<AppSecretsRepository>();

  // Socket
  late IO.Socket? socket;

  ChatController getChatController(String chatId) {
    try {
      return _chatControllers[chatId]!;
    } catch (e) {
      throw Exception("Chat Controller not found");
    }
  }

  Future<void> _onCentralChatEvent(
    CentralChatEvent event,
    Emitter<CentralChatState> emit,
  ) async {
    await event.when(
      loadProfiles: () async {
        await _loadProfiles(emit);
      },
      forcedLoadProfiles: () async {
        await _forceLoadProfiles(emit);
      },
      loadChats: () async {
        await _loadChats();
      },
      initalizeUserStatusSocket: (userId) {
        this.userId = userId;
        _initializeSocket();
      },
      updateUserStatus: (Status status) async {
        _changeUserStatus(status, emit);
      },
    );
  }

  void _initializeSocket() {
    String url =
        'wss://${_appSecretsRepository.getSecret(AppSecretsKeys.USER_STATUS_SOCKET_URL)}';
    socket = IO.io(
      url,
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'userid': userId,
      }).build(),
    );
    socket?.connect();
    socket?.onConnect((data) => _logger.info('Connected to socket'));
  }

  Stream<int> showMessageNotificationStream() {
    // merge all chat controllers' new message streams
    return Rx.combineLatest(
      _chatControllers.values.map((e) => e.newMessageCount),
      (List<int?> newMessageCounts) {
        return newMessageCounts.fold<int>(
          0,
          (previousValue, element) => previousValue + (element ?? 0),
        );
      },
    );
  }

  void _changeUserStatus(Status status, Emitter<CentralChatState> emit) async {
    try {
      socket?.emit(
        'update',
        {'user_status': status == Status.ONLINE},
      );
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  bool doesChatExists(String chatId) {
    return _chatControllers.containsKey(chatId);
  }

  FutureOr<void> _loadProfiles(Emitter<CentralChatState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      // ================== Load from local storage ==================
      List<QuickChatUser> chatUsers =
          _obxStorageRepository.getChatUserProfiles();
      if (chatUsers.isNotEmpty) {
        _updateChatController(
          chatUsers.map(
            (e) {
              return ChatInfo(
                chatId: e.chatId ?? '',
                recipientUser: e,
                senderId: userId,
                receiverId: e.userId ?? '',
              );
            },
          ).toList(),
        );
        emit(
          state.copyWith(
            chatStates:
                _chatControllers.values.map((e) => e.toChatInfo()).toList(),
          ),
        );
      }
      // ================== Load from remote ==================
      await emit.forEach(
        getRecipientUsersStream(),
        onData: (data) {
          List<ChatInfo> chatStates = data
              .map((recipient) => ChatInfo(
                    chatId: recipient.chatId ?? '',
                    recipientUser: recipient,
                    senderId: userId,
                    receiverId: recipient.userId ?? '',
                  ))
              .toList();
          _updateChatController(chatStates);
          return state.copyWith(chatStates: chatStates, isLoading: false);
        },
      );
      emit(
        state.copyWith(
          chatStates:
              _chatControllers.values.map((e) => e.toChatInfo()).toList(),
        ),
      );
      add(const CentralChatEvent.loadChats());
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  Future<void> _loadChats() async {}

  Future<void> _forceLoadProfiles(Emitter<CentralChatState> emit) async {
    try {
      // ================== Load from remote (force) ==================
      emit(state.copyWith(isLoading: true));
      List<ChatInfo> chatStates = [];
      List<ChatController> chatControllers = await _fetchRemoteRecipientUsers();
      for (ChatController chatHandler in chatControllers) {
        chatStates.add(chatHandler.toChatInfo());
      }
      _updateChatController(chatStates);
      emit(state.copyWith(chatStates: chatStates, isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  Stream<List<QuickChatUser>> getRecipientUsersStream() {
    // ================== Stream on User Home page to listen for oncoming new recipient users ==================
    return _recipientUserRepository.getRecipientUsersStream(userId,
        (senderId, receiverId) {
      return _chatRepository.generateChatId(senderId, receiverId);
    }).map((chatUsers) {
      for (QuickChatUser user in chatUsers) {
        ChatController chatController = _createChatController(user, userId);
        _addToChatController(chatController);
      }
      unawaited(_obxStorageRepository.updateChatUser(chatUsers));
      return chatUsers;
    });
  }

  void _updateChatController(List<ChatInfo> chatStates) {
    // ================== Update chat handlers ==================
    for (ChatInfo chatState in chatStates) {
      ChatController chatHandler = _createChatController(
        chatState.recipientUser,
        userId,
      );
      _addToChatController(chatHandler);
      log("Intialized Chat Handler: ${chatHandler.liveChatStream}");
    }
  }

  void _addToChatController(ChatController chatHandler) {
    // ================== Add chat controllers to the map ==================
    bool chatExists = false;
    for (ChatController handler in _chatControllers.values) {
      if (handler.recipientUser.userId == chatHandler.recipientUser.userId) {
        chatExists = true;
        break;
      }
    }
    if (!chatExists) {
      _chatControllers.putIfAbsent(chatHandler.chatId, () {
        return chatHandler;
      });
    }
  }

  ChatController _createChatController(
      QuickChatUser recipientUser, String senderId) {
    return ChatController(
      chatId: recipientUser.chatId!,
      senderId: senderId,
      receiverId: recipientUser.userId!,
      recipientUser: recipientUser,
      localChatSubscription:
          _obxStorageRepository.getChatMessagesSubject(recipientUser.chatId!),
      remoteChatStream: (epochTime) {
        return _chatRepository.getChatMessagesSubject(recipientUser.chatId!);
      },
      storage: _obxStorageRepository,
    );
  }

  Future<List<ChatController>> _fetchRemoteRecipientUsers() async {
    List<QuickChatUser> chatUsers = await _recipientUserRepository
        .getRecipientUsers(userId, (senderId, receiverId) {
      return _chatRepository.generateChatId(senderId, receiverId);
    });
    List<ChatController> chatControllers = [];
    for (QuickChatUser user in chatUsers) {
      chatControllers.add(_createChatController(user, userId));
    }
    unawaited(_obxStorageRepository.updateChatUser(chatUsers));
    unawaited(_localStorage.saveInt(LocalStorageKeys.lastSavedRecipientUsers,
        DateTime.now().millisecondsSinceEpoch));
    return chatControllers;
  }

  ChatInfo? checkChatExists(String receiverUserId) {
    for (ChatController chatController in _chatControllers.values) {
      if (chatController.receiverId == receiverUserId) {
        return chatController.toChatInfo();
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    _recipientUserStreamSubscription?.cancel();
    for (ChatController chatHandler in _chatControllers.values) {
      chatHandler.closeChat();
    }
    return super.close();
  }
}
