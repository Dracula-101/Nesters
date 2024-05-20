part of 'central_chat_bloc.dart';

@freezed
class CentralChatState with _$CentralChatState {
  const factory CentralChatState({
    required List<ChatState> chatStates,
    required bool isLoading,
    required Exception? error,
  }) = _CentralChatState;

  factory CentralChatState.loading() => const CentralChatState(
        chatStates: [],
        isLoading: true,
        error: null,
      );

  factory CentralChatState.noChatsAvailable() => const CentralChatState(
        chatStates: [],
        isLoading: false,
        error: null,
      );

  factory CentralChatState.error(Exception e) => CentralChatState(
        chatStates: [],
        isLoading: false,
        error: e,
      );

  factory CentralChatState.loaded(List<ChatState> chatStates) => CentralChatState(
        chatStates: chatStates,
        isLoading: false,
        error: null,
      );
}

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required String chatId,
    required String senderId,
    required String receiverId,
    required QuickChatUser recipientUser,
  }) = _ChatState;
}
