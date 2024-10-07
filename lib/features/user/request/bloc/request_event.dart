part of 'request_bloc.dart';

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
    required R Function() started,
    required R Function() loadUsers,
    required R Function(RequestScreen screeb) changeScreen,
    required R Function(String userId) sendRequest,
    required R Function(String userId) acceptRequest,
    required R Function(String userId) rejectRequest,
    required R Function(String userId) cancelRequest,
    required R Function() clearSentRequestStatus,
  }) {
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
    } else {
      throw Exception('Unknown event: $this');
    }
  }

  R maybeMap<R>({
    R Function()? started,
    R Function()? loadUsers,
    R Function(RequestScreen screeb)? changeScreen,
    R Function(String userId)? sendRequest,
    R Function(String userId)? acceptRequest,
    R Function(String userId)? rejectRequest,
    R Function(String userId)? cancelRequest,
    R Function()? clearSentRequestStatus,
    required R Function(RequestEvent) orElse,
  }) {
    if (this is _Started) {
      return started?.call() ?? orElse.call(this);
    } else if (this is _LoadUsers) {
      return loadUsers?.call() ?? orElse.call(this);
    } else if (this is _ChangeScreen) {
      return changeScreen?.call((this as _ChangeScreen).screen) ??
          orElse.call(this);
    } else if (this is _SendRequest) {
      return sendRequest?.call((this as _SendRequest).userId) ??
          orElse.call(this);
    } else if (this is _AcceptRequest) {
      return acceptRequest?.call((this as _AcceptRequest).userId) ??
          orElse.call(this);
    } else if (this is _RejectRequest) {
      return rejectRequest?.call((this as _RejectRequest).userId) ??
          orElse.call(this);
    } else if (this is _CancelRequest) {
      return cancelRequest?.call((this as _CancelRequest).userId) ??
          orElse.call(this);
    } else if (this is _ClearSentRequestStatus) {
      return clearSentRequestStatus?.call() ?? orElse.call(this);
    } else {
      return orElse.call(this);
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
