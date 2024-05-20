part of 'central_chat_bloc.dart';

@freezed
class CentralChatEvent with _$CentralChatEvent {
  const factory CentralChatEvent.forcedLoadProfiles() = _ForcedLoadProfiles;
  const factory CentralChatEvent.listenToProfiles() = _ListenToProfiles;
  const factory CentralChatEvent.loadChats() = _LoadChats;
  const factory CentralChatEvent.loadProfiles(String userId) = _LoadProfiles;
  const factory CentralChatEvent.sendMessage(String chatId, Message message) =
      _SendMessage;
}
