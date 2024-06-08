part of 'central_chat_bloc.dart';

@freezed
class CentralChatEvent with _$CentralChatEvent {
  const factory CentralChatEvent.forcedLoadProfiles() = _ForcedLoadProfiles;
  const factory CentralChatEvent.loadChats() = _LoadChats;
  const factory CentralChatEvent.loadProfiles() = _LoadProfiles;
  const factory CentralChatEvent.initalizeUserStatusSocket(String userId) =
      _InitalizeUserStatusSocket;
  const factory CentralChatEvent.updateUserStatus(Status status) =
      _UpdateUserStatus;
}
