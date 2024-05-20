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
import 'package:nesters/features/user/chat/bloc/components/chat_handler.dart';
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

  ChatHandler getChatHandler(String chatId) {
    return _chatHandlers[chatId]!;
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
      forcedLoadProfiles: () async {
        await _forceLoadProfiles(emit);
      },
      loadChats: () async {
        await _loadChats();
      },
    );
  }

  FutureOr<void> _loadProfiles(Emitter<CentralChatState> emit) async {
    try {
      emit(CentralChatState.loading());
      // ================== Load from local storage ==================
      List<QuickChatUser> chatUsers =
          _obxStorageRepository.getChatUserProfiles();
      if (chatUsers.isNotEmpty) {
        _updateChatHandlers(
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
          CentralChatState.loaded(
            _chatHandlers.values.map((e) => e.toChatState()).toList(),
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
          _updateChatHandlers(chatStates);
          return state.copyWith(chatStates: chatStates, isLoading: false);
        },
      );
      emit(
        CentralChatState.loaded(
          _chatHandlers.values.map((e) => e.toChatState()).toList(),
        ),
      );
      add(const CentralChatEvent.loadChats());
    } on Exception catch (e) {
      emit(CentralChatState.error(e));
    }
  }

  Future<void> _loadChats() async {}

  Future<void> _forceLoadProfiles(Emitter<CentralChatState> emit) async {
    try {
      // ================== Load from remote (force) ==================
      emit(CentralChatState.loading());
      List<ChatInfo> chatStates = [];
      List<ChatHandler> chatHandlers = await _fetchRemoteRecipientUsers();
      for (ChatHandler chatHandler in chatHandlers) {
        chatStates.add(chatHandler.toChatState());
      }
      _updateChatHandlers(chatStates);
      for (ChatHandler chatHandler in _chatHandlers.values) {
        chatStates.add(chatHandler.toChatState());
      }

      emit(CentralChatState.loaded(chatStates));
    } on Exception catch (e) {
      emit(CentralChatState.error(e));
    }
  }

  Stream<List<QuickChatUser>> getRecipientUsersStream() {
    // ================== Stream on User Home page to listen for oncoming new recipient users ==================
    return _recipientUserRepository.getRecipientUsersStream(userId,
        (senderId, receiverId) {
      return _chatRepository.generateChatId(senderId, receiverId);
    }).map((chatUsers) {
      for (QuickChatUser user in chatUsers) {
        ChatHandler chatHandler = _createChatHandler(user, userId);
        _addToChatHandlers(chatHandler);
      }
      unawaited(_obxStorageRepository.updateChatUser(chatUsers));
      return chatUsers;
    });
  }

  void _updateChatHandlers(List<ChatInfo> chatStates) {
    // ================== Update chat handlers ==================
    for (ChatInfo chatState in chatStates) {
      ChatHandler chatHandler = _createChatHandler(
        chatState.recipientUser,
        userId,
      );
      StreamSubscription<List<Message>> remoteChatSubscription =
          _chatRepository.getChatMessages(chatHandler.chatId).listen(null);
      chatHandler.addRemoteMessageListener(remoteChatSubscription);
      _addToChatHandlers(chatHandler);
      log("Intialized Chat Handler: ${chatHandler.liveChatStream}");
    }
  }

  void _addToChatHandlers(ChatHandler chatHandler) {
    // ================== Add chat handler to the map ==================
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
    );
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

  @override
  Future<void> close() {
    _recipientUserStreamSubscription?.cancel();
    for (ChatHandler chatHandler in _chatHandlers.values) {
      chatHandler.dispose();
    }
    return super.close();
  }
}
