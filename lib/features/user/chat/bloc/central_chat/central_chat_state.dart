part of 'central_chat_bloc.dart';

class CentralChatState {
  final List<ChatInfo> chatStates;
  final Exception? error;
  final bool isLoading;

  const CentralChatState({
    this.chatStates = const [],
    this.error,
    this.isLoading = true,
  });

  CentralChatState copyWith({
    List<ChatInfo>? chatStates,
    Exception? error,
    bool? isLoading,
  }) {
    return CentralChatState(
      chatStates: chatStates ?? this.chatStates,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CentralChatState &&
        listEquals(other.chatStates, chatStates) &&
        other.error == error &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => chatStates.hashCode ^ error.hashCode ^ isLoading.hashCode;
}

class ChatInfo {
  final String chatId;
  final String receiverId;
  final QuickChatUser recipientUser;
  final String senderId;

  ChatInfo({
    required this.chatId,
    required this.receiverId,
    required this.recipientUser,
    required this.senderId,
  });

  ChatInfo copyWith({
    String? chatId,
    String? receiverId,
    QuickChatUser? recipientUser,
    String? senderId,
  }) {
    return ChatInfo(
      chatId: chatId ?? this.chatId,
      receiverId: receiverId ?? this.receiverId,
      recipientUser: recipientUser ?? this.recipientUser,
      senderId: senderId ?? this.senderId,
    );
  }
}
