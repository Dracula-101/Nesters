part of 'chat_bloc.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.loadChats(chatId) = _LoadChats;
  const factory ChatEvent.checkChat(String senderId, String receiverId) =
      _CheckChat;
  const factory ChatEvent.disposeChatSubscription() = _DisposeChatSubscription;
  const factory ChatEvent.sendMessage(Message message) = _SendMessage;
}
