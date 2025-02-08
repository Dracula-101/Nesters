part of 'chat_bloc.dart';

// @freezed
// class ChatState with _$ChatState {
//   const factory ChatState({
//     required bool isLoading,
//     String? chatId,
//     String? senderId,
//     String? receiverId,
//     Map<DocumentSource, DocumentUploadTask>? uploadTask,
//     @Default(false) bool doesChatExist,
//     Exception? error,
//   }) = _ChatState;

//   factory ChatState.initial() => const ChatState(isLoading: true);
// }

class ChatState {
  final bool isLoading;
  final String? chatId;
  final String? senderId;
  final String? receiverId;
  final Map<DocumentSource, DocumentUploadTask>? uploadTask;
  final bool doesChatExist;
  final bool isLoadingMedia;
  final Exception? error;

  const ChatState({
    this.isLoading = true,
    this.chatId,
    this.senderId,
    this.receiverId,
    this.uploadTask,
    this.isLoadingMedia = false,
    this.doesChatExist = false,
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    String? chatId,
    String? senderId,
    String? receiverId,
    Map<DocumentSource, DocumentUploadTask>? uploadTask,
    bool? isLoadingMedia,
    bool? doesChatExist,
    Exception? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      uploadTask: uploadTask ?? this.uploadTask,
      isLoadingMedia: isLoadingMedia ?? this.isLoadingMedia,
      doesChatExist: doesChatExist ?? this.doesChatExist,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatState &&
        other.isLoading == isLoading &&
        other.chatId == chatId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        mapEquals(other.uploadTask, uploadTask) &&
        other.isLoadingMedia == isLoadingMedia &&
        other.doesChatExist == doesChatExist &&
        other.error == error;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        chatId.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        uploadTask.hashCode ^
        isLoadingMedia.hashCode ^
        doesChatExist.hashCode ^
        error.hashCode;
  }
}

enum DocumentSource {
  CAMERA,
  GALLERY,
}
