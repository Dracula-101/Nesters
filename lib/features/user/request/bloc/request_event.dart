part of 'request_bloc.dart';

@freezed
class RequestEvent with _$RequestEvent {
  const factory RequestEvent.started() = _Started;
  const factory RequestEvent.loadUsers() = _LoadUsers;
  const factory RequestEvent.changeScreen(RequestScreen screen) = _ChangeScreen;
  const factory RequestEvent.sendRequest(String userId) = _SendRequest;
  const factory RequestEvent.acceptRequest(String userId) = _AcceptRequest;
  const factory RequestEvent.rejectRequest(String userId) = _RejectRequest;
  const factory RequestEvent.cancelRequest(String userId) = _CancelRequest;

  const factory RequestEvent.clearSentRequestStatus() = _ClearSentRequestStatus;
}
