part of 'central_chat_bloc.dart';

@freezed
class CentralChatState with _$CentralChatState {
  const factory CentralChatState({
    required List<ChatInfo> chatStates,
    required Exception? error,
    required bool isLoading,
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

  factory CentralChatState.loaded(List<ChatInfo> chatStates) =>
      CentralChatState(
        chatStates: chatStates,
        isLoading: false,
        error: null,
      );
}

@freezed
class ChatInfo with _$ChatInfo {
  const factory ChatInfo({
    required String chatId,
    required QuickChatUser recipientUser,
    required String receiverId,
    required String senderId,
  }) = _ChatInfo;
}
