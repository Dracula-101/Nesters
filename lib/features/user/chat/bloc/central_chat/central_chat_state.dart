part of 'central_chat_bloc.dart';
class CentralChatState {
  final List<ChatInfo> chatStates;
  final BlocState chatState;

  const CentralChatState({
    this.chatStates = const [],
    this.chatState = const BlocState(),
  });

  CentralChatState copyWith({
    List<ChatInfo>? chatStates,
    BlocState? chatState,
  }) {
    return CentralChatState(
      chatStates: chatStates ?? this.chatStates,
      chatState: chatState ?? this.chatState,
    );
  }
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
