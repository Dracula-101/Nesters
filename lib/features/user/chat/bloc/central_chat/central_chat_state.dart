part of 'central_chat_bloc.dart';

// @freezed
// class CentralChatState with _$CentralChatState {
//   const factory CentralChatState({
//     required List<ChatInfo> chatStates,
//     required Exception? error,
//     required bool isLoading,
//   }) = _CentralChatState;

//   factory CentralChatState.error(Exception e) => CentralChatState(
//         chatStates: [],
//         isLoading: false,
//         error: e,
//       );

//   factory CentralChatState.loaded(List<ChatInfo> chatStates) =>
//       CentralChatState(
//         chatStates: chatStates,
//         isLoading: false,
//         error: null,
//       );

//   factory CentralChatState.loading() => const CentralChatState(
//         chatStates: [],
//         isLoading: true,
//         error: null,
//       );

//   factory CentralChatState.noChatsAvailable() => const CentralChatState(
//         chatStates: [],
//         isLoading: false,
//         error: null,
//       );
// }

// @freezed
// class ChatInfo with _$ChatInfo {
//   const factory ChatInfo({
//     required String chatId,
//     required String receiverId,
//     required QuickChatUser recipientUser,
//     required String senderId,
//   }) = _ChatInfo;
// }

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
