part of 'central_chat_bloc.dart';

// @freezed
// class CentralChatEvent with _$CentralChatEvent {
//   const factory CentralChatEvent.forcedLoadProfiles() = _ForcedLoadProfiles;
//   const factory CentralChatEvent.loadChats() = _LoadChats;
//   const factory CentralChatEvent.loadProfiles() = _LoadProfiles;
//   const factory CentralChatEvent.initalizeUserStatusSocket(String userId) =
//       _InitalizeUserStatusSocket;
//   const factory CentralChatEvent.updateUserStatus(Status status) =
//       _UpdateUserStatus;
// }

abstract class CentralChatEvent {
  const CentralChatEvent();

  const factory CentralChatEvent.forcedLoadProfiles() = _ForcedLoadProfiles;
  const factory CentralChatEvent.loadChats() = _LoadChats;
  const factory CentralChatEvent.loadProfiles() = _LoadProfiles;
  const factory CentralChatEvent.initalizeUserStatusSocket(String userId) =
      _InitalizeUserStatusSocket;
  const factory CentralChatEvent.updateUserStatus(Status status) =
      _UpdateUserStatus;

  R when<R>({
    required R Function() forcedLoadProfiles,
    required R Function() loadChats,
    required R Function() loadProfiles,
    required R Function(String userId) initalizeUserStatusSocket,
    required R Function(Status status) updateUserStatus,
  }) {
    if (this is _ForcedLoadProfiles) {
      return forcedLoadProfiles();
    } else if (this is _LoadChats) {
      return loadChats();
    } else if (this is _LoadProfiles) {
      return loadProfiles();
    } else if (this is _InitalizeUserStatusSocket) {
      return initalizeUserStatusSocket(
          (this as _InitalizeUserStatusSocket).userId);
    } else if (this is _UpdateUserStatus) {
      return updateUserStatus((this as _UpdateUserStatus).status);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeWhen<R>({
    R Function()? forcedLoadProfiles,
    R Function()? loadChats,
    R Function()? loadProfiles,
    R Function(String userId)? initalizeUserStatusSocket,
    R Function(Status status)? updateUserStatus,
    required R Function() orElse,
  }) {
    if (this is _ForcedLoadProfiles) {
      return forcedLoadProfiles != null ? forcedLoadProfiles() : orElse();
    } else if (this is _LoadChats) {
      return loadChats != null ? loadChats() : orElse();
    } else if (this is _LoadProfiles) {
      return loadProfiles != null ? loadProfiles() : orElse();
    } else if (this is _InitalizeUserStatusSocket) {
      return initalizeUserStatusSocket != null
          ? initalizeUserStatusSocket(
              (this as _InitalizeUserStatusSocket).userId)
          : orElse();
    } else if (this is _UpdateUserStatus) {
      return updateUserStatus != null
          ? updateUserStatus((this as _UpdateUserStatus).status)
          : orElse();
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R map<R>({
    required R Function() forcedLoadProfiles,
    required R Function() loadChats,
    required R Function() loadProfiles,
    required R Function(String userId) initalizeUserStatusSocket,
    required R Function(Status status) updateUserStatus,
  }) {
    if (this is _ForcedLoadProfiles) {
      return forcedLoadProfiles();
    } else if (this is _LoadChats) {
      return loadChats();
    } else if (this is _LoadProfiles) {
      return loadProfiles();
    } else if (this is _InitalizeUserStatusSocket) {
      return initalizeUserStatusSocket(
          (this as _InitalizeUserStatusSocket).userId);
    } else if (this is _UpdateUserStatus) {
      return updateUserStatus((this as _UpdateUserStatus).status);
    } else {
      throw StateError('Unknown type $this');
    }
  }

  R maybeMap<R>({
    R Function()? forcedLoadProfiles,
    R Function()? loadChats,
    R Function()? loadProfiles,
    R Function(String userId)? initalizeUserStatusSocket,
    R Function(Status status)? updateUserStatus,
    required R Function(CentralChatEvent) orElse,
  }) {
    if (this is _ForcedLoadProfiles) {
      return forcedLoadProfiles != null ? forcedLoadProfiles() : orElse(this);
    } else if (this is _LoadChats) {
      return loadChats != null ? loadChats() : orElse(this);
    } else if (this is _LoadProfiles) {
      return loadProfiles != null ? loadProfiles() : orElse(this);
    } else if (this is _InitalizeUserStatusSocket) {
      return initalizeUserStatusSocket != null
          ? initalizeUserStatusSocket(
              (this as _InitalizeUserStatusSocket).userId)
          : orElse(this);
    } else if (this is _UpdateUserStatus) {
      return updateUserStatus != null
          ? updateUserStatus((this as _UpdateUserStatus).status)
          : orElse(this);
    } else {
      throw StateError('Unknown type $this');
    }
  }
}

class _ForcedLoadProfiles extends CentralChatEvent {
  const _ForcedLoadProfiles();
}

class _LoadChats extends CentralChatEvent {
  const _LoadChats();
}

class _LoadProfiles extends CentralChatEvent {
  const _LoadProfiles();
}

class _InitalizeUserStatusSocket extends CentralChatEvent {
  const _InitalizeUserStatusSocket(this.userId);

  final String userId;
}

class _UpdateUserStatus extends CentralChatEvent {
  const _UpdateUserStatus(this.status);

  final Status status;
}
