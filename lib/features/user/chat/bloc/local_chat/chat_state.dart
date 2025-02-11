part of 'chat_bloc.dart';

class ChatState {
  final ChatLoadingState? chatState;
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final Map<DocumentSource, DocumentUploadTask>? uploadTask;
  final bool doesChatExist;
  final bool isLoadingMedia;

  const ChatState({
    this.chatState,
    this.chatId,
    this.senderId,
    this.receiverId,
    this.uploadTask,
    this.isLoadingMedia = false,
    this.doesChatExist = false,
  });

  ChatState copyWith({
    ChatLoadingState? chatState,
    String? chatId,
    String? senderId,
    String? receiverId,
    Map<DocumentSource, DocumentUploadTask>? uploadTask,
    bool? isLoadingMedia,
    bool? doesChatExist,
  }) {
    return ChatState(
      chatState: chatState ?? this.chatState,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      uploadTask: uploadTask ?? this.uploadTask,
      isLoadingMedia: isLoadingMedia ?? this.isLoadingMedia,
      doesChatExist: doesChatExist ?? this.doesChatExist,
    );
  }
}

enum DocumentSource {
  CAMERA,
  GALLERY,
}
