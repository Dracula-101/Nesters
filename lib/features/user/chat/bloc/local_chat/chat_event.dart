part of 'chat_bloc.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.loadChats(String chatId) = _LoadChats;
  const factory ChatEvent.checkChat(String senderId, String receiverId) =
      _CheckChat;
  const factory ChatEvent.closeChat() = _CancelChatSubscription;
  const factory ChatEvent.sendMessage(Message message) = _SendMessage;
  const factory ChatEvent.sendDocument(DocumentSource source, String senderId) =
      _SendDocument;
  const factory ChatEvent.downloadDocument(
      String url, VoidCallback onComplete) = _DownloadDocument;
}
