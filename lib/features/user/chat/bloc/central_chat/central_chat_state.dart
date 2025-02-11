part of 'central_chat_bloc.dart';

class ChatLoadingState extends BlocState {
  ChatLoadingState({
    bool isLoading = false,
    AppException? error,
    bool isSuccess = false,
  }) : super(
          isLoading: isLoading,
          exception: error,
          isSuccess: isSuccess,
        );

  @override
  ChatLoadingState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return ChatLoadingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  ChatLoadingState failure(AppException error) {
    return ChatLoadingState(
      isLoading: false,
      error: error,
      isSuccess: false,
    );
  }

  @override
  ChatLoadingState loading() {
    return ChatLoadingState(
      isLoading: true,
      error: null,
      isSuccess: false,
    );
  }

  @override
  ChatLoadingState resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  ChatLoadingState success() {
    return ChatLoadingState(
      isLoading: false,
      error: null,
      isSuccess: true,
    );
  }
}

class CentralChatState {
  final List<ChatInfo> chatStates;
  final ChatLoadingState? chatState;

  const CentralChatState({
    this.chatStates = const [],
    this.chatState,
  });

  CentralChatState copyWith({
    List<ChatInfo>? chatStates,
    ChatLoadingState? chatState,
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
