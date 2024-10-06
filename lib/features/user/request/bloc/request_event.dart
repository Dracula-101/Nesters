part of 'request_bloc.dart';

// @freezed
// class RequestEvent with _$RequestEvent {
//   const factory RequestEvent.started() = _Started;
//   const factory RequestEvent.loadUsers() = _LoadUsers;
//   const factory RequestEvent.changeScreen(RequestScreen screen) = _ChangeScreen;
//   const factory RequestEvent.sendRequest(String userId) = _SendRequest;
//   const factory RequestEvent.acceptRequest(String userId) = _AcceptRequest;
//   const factory RequestEvent.rejectRequest(String userId) = _RejectRequest;
//   const factory RequestEvent.cancelRequest(String userId) = _CancelRequest;

//   const factory RequestEvent.clearSentRequestStatus() = _ClearSentRequestStatus;
// }

abstract class RequestEvent {
  const RequestEvent();

  const factory RequestEvent.started() = _Started;
  const factory RequestEvent.loadUsers() = _LoadUsers;
  const factory RequestEvent.changeScreen(RequestScreen screen) = _ChangeScreen;
  const factory RequestEvent.sendRequest(String userId) = _SendRequest;
  const factory RequestEvent.acceptRequest(String userId) = _AcceptRequest;
  const factory RequestEvent.rejectRequest(String userId) = _RejectRequest;
  const factory RequestEvent.cancelRequest(String userId) = _CancelRequest;
  const factory RequestEvent.clearSentRequestStatus() = _ClearSentRequestStatus;

  Future<void> when({
    required Future<void> Function() started,
    required Future<void> Function() loadUsers,
    required Future<void> Function(RequestScreen screen) changeScreen,
    required Future<void> Function(String userId) sendRequest,
    required Future<void> Function(String userId) acceptRequest,
    required Future<void> Function(String userId) rejectRequest,
    required Future<void> Function(String userId) cancelRequest,
    required Future<void> Function() clearSentRequestStatus,
  }) async {
    if (this is _Started) {
      return started();
    } else if (this is _LoadUsers) {
      return loadUsers();
    } else if (this is _ChangeScreen) {
      return changeScreen((this as _ChangeScreen).screen);
    } else if (this is _SendRequest) {
      return sendRequest((this as _SendRequest).userId);
    } else if (this is _AcceptRequest) {
      return acceptRequest((this as _AcceptRequest).userId);
    } else if (this is _RejectRequest) {
      return rejectRequest((this as _RejectRequest).userId);
    } else if (this is _CancelRequest) {
      return cancelRequest((this as _CancelRequest).userId);
    } else if (this is _ClearSentRequestStatus) {
      return clearSentRequestStatus();
    }
  }

  R maybeWhen<R>({
    R Function()? started,
    R Function()? loadUsers,
    R Function(RequestScreen screen)? changeScreen,
    R Function(String userId)? sendRequest,
    R Function(String userId)? acceptRequest,
    R Function(String userId)? rejectRequest,
    R Function(String userId)? cancelRequest,
    R Function()? clearSentRequestStatus,
    required R Function() orElse,
  }) {
    if (this is _Started) {
      return started?.call() ?? orElse.call();
    } else if (this is _LoadUsers) {
      return loadUsers?.call() ?? orElse.call();
    } else if (this is _ChangeScreen) {
      return changeScreen?.call((this as _ChangeScreen).screen) ??
          orElse.call();
    } else if (this is _SendRequest) {
      return sendRequest?.call((this as _SendRequest).userId) ?? orElse.call();
    } else if (this is _AcceptRequest) {
      return acceptRequest?.call((this as _AcceptRequest).userId) ??
          orElse.call();
    } else if (this is _RejectRequest) {
      return rejectRequest?.call((this as _RejectRequest).userId) ??
          orElse.call();
    } else if (this is _CancelRequest) {
      return cancelRequest?.call((this as _CancelRequest).userId) ??
          orElse.call();
    } else if (this is _ClearSentRequestStatus) {
      return clearSentRequestStatus?.call() ?? orElse.call();
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R map<R>({
    required R Function(_Started) started,
    required R Function(_LoadUsers) loadUsers,
    required R Function(_ChangeScreen) changeScreen,
    required R Function(_SendRequest) sendRequest,
    required R Function(_AcceptRequest) acceptRequest,
    required R Function(_RejectRequest) rejectRequest,
    required R Function(_CancelRequest) cancelRequest,
    required R Function(_ClearSentRequestStatus) clearSentRequestStatus,
  }) {
    if (this is _Started) {
      return started(this as _Started);
    } else if (this is _LoadUsers) {
      return loadUsers(this as _LoadUsers);
    } else if (this is _ChangeScreen) {
      return changeScreen(this as _ChangeScreen);
    } else if (this is _SendRequest) {
      return sendRequest(this as _SendRequest);
    } else if (this is _AcceptRequest) {
      return acceptRequest(this as _AcceptRequest);
    } else if (this is _RejectRequest) {
      return rejectRequest(this as _RejectRequest);
    } else if (this is _CancelRequest) {
      return cancelRequest(this as _CancelRequest);
    } else if (this is _ClearSentRequestStatus) {
      return clearSentRequestStatus(this as _ClearSentRequestStatus);
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeMap<R>({
    R Function(_Started)? started,
    R Function(_LoadUsers)? loadUsers,
    R Function(_ChangeScreen)? changeScreen,
    R Function(_SendRequest)? sendRequest,
    R Function(_AcceptRequest)? acceptRequest,
    R Function(_RejectRequest)? rejectRequest,
    R Function(_CancelRequest)? cancelRequest,
    R Function(_ClearSentRequestStatus)? clearSentRequestStatus,
    required R Function(RequestEvent) orElse,
  }) {
    if (this is _Started) {
      return started?.call(this as _Started) ?? orElse.call(this);
    } else if (this is _LoadUsers) {
      return loadUsers?.call(this as _LoadUsers) ?? orElse.call(this);
    } else if (this is _ChangeScreen) {
      return changeScreen?.call(this as _ChangeScreen) ?? orElse.call(this);
    } else if (this is _SendRequest) {
      return sendRequest?.call(this as _SendRequest) ?? orElse.call(this);
    } else if (this is _AcceptRequest) {
      return acceptRequest?.call(this as _AcceptRequest) ?? orElse.call(this);
    } else if (this is _RejectRequest) {
      return rejectRequest?.call(this as _RejectRequest) ?? orElse.call(this);
    } else if (this is _CancelRequest) {
      return cancelRequest?.call(this as _CancelRequest) ?? orElse.call(this);
    } else if (this is _ClearSentRequestStatus) {
      return clearSentRequestStatus?.call(this as _ClearSentRequestStatus) ??
          orElse.call(this);
    } else {
      throw Exception('Unknown event: $this');
    }
  }
}

class _Started extends RequestEvent {
  const _Started();
}

class _LoadUsers extends RequestEvent {
  const _LoadUsers();
}

class _ChangeScreen extends RequestEvent {
  final RequestScreen screen;

  const _ChangeScreen(this.screen);
}

class _SendRequest extends RequestEvent {
  final String userId;

  const _SendRequest(this.userId);
}

class _AcceptRequest extends RequestEvent {
  final String userId;

  const _AcceptRequest(this.userId);
}

class _RejectRequest extends RequestEvent {
  final String userId;

  const _RejectRequest(this.userId);
}

class _CancelRequest extends RequestEvent {
  final String userId;

  const _CancelRequest(this.userId);
}

class _ClearSentRequestStatus extends RequestEvent {
  const _ClearSentRequestStatus();
}
