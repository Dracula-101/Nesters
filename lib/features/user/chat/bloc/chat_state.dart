part of 'chat_bloc.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required bool isLoading,
    String? chatId,
    @Default(false) bool doesChatExist,
    Exception? error,
  }) = _ChatState;

  factory ChatState.initial() => const ChatState(
        isLoading: true,
      );
}
