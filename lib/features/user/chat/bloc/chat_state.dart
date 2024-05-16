part of 'chat_bloc.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required bool isLoading,
    String? chatId,
    Map<DocumentSource, DocumentUploadTask>? uploadTask,
    @Default(false) bool doesChatExist,
    Exception? error,
  }) = _ChatState;

  factory ChatState.initial() => const ChatState(isLoading: true);
}

enum DocumentSource {
  CAMERA,
  GALLERY,
}
