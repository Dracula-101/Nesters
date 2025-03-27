// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

enum UserChatProfileErrorCode {
  GET_PROFILE_ERR,
  GET_SENT_REQ_ERR,
  GET_RECEIVED_REQ_ERR,
  SEND_REQ_ERR,
  CREATE_CHAT_ROOM_ERR,
  ACCEPT_REQ_ERR,
  REJECT_REQ_ERR,
  DELETE_USER_ERR,
}

abstract class UserChatProfileError extends AppException {
  UserChatProfileErrorCode code;

  @override
  String message;

  UserChatProfileError({
    required this.code,
    required this.message,
  });
}

class GetProfileError extends UserChatProfileError {
  String extra;

  GetProfileError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.GET_PROFILE_ERR,
          message: 'Failed to get profile: $extra',
        );
}

class GetSentReqError extends UserChatProfileError {
  String extra;

  GetSentReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.GET_SENT_REQ_ERR,
          message: 'Failed to get sent requests: $extra',
        );
}

class GetReceivedReqError extends UserChatProfileError {
  String extra;

  GetReceivedReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.GET_RECEIVED_REQ_ERR,
          message: 'Failed to get received requests: $extra',
        );
}

class CreateChatRoomError extends UserChatProfileError {
  String extra;

  CreateChatRoomError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.CREATE_CHAT_ROOM_ERR,
          message: 'Failed to create chat room: $extra',
        );
}

class SendReqError extends UserChatProfileError {
  String extra;

  SendReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.SEND_REQ_ERR,
          message: 'Failed to send request: $extra',
        );
}

class AcceptReqError extends UserChatProfileError {
  String extra;

  AcceptReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.ACCEPT_REQ_ERR,
          message: 'Failed to accept request: $extra',
        );
}

class RejectReqError extends UserChatProfileError {
  String extra;

  RejectReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.REJECT_REQ_ERR,
          message: 'Failed to reject request: $extra',
        );
}

class DeleteUserError extends UserChatProfileError {
  String extra;

  DeleteUserError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.DELETE_USER_ERR,
          message: 'Failed to delete user: $extra',
        );
}

class UserChatProfileErrorFactory {
  static UserChatProfileError create(
      UserChatProfileErrorCode code, String extra) {
    switch (code) {
      case UserChatProfileErrorCode.GET_PROFILE_ERR:
        return GetProfileError(extra: extra);
      case UserChatProfileErrorCode.GET_SENT_REQ_ERR:
        return GetSentReqError(extra: extra);
      case UserChatProfileErrorCode.GET_RECEIVED_REQ_ERR:
        return GetReceivedReqError(extra: extra);
      case UserChatProfileErrorCode.SEND_REQ_ERR:
        return SendReqError(extra: extra);
      case UserChatProfileErrorCode.ACCEPT_REQ_ERR:
        return AcceptReqError(extra: extra);
      case UserChatProfileErrorCode.REJECT_REQ_ERR:
        return RejectReqError(extra: extra);
      case UserChatProfileErrorCode.DELETE_USER_ERR:
        return DeleteUserError(extra: extra);
      case UserChatProfileErrorCode.CREATE_CHAT_ROOM_ERR:
        return CreateChatRoomError(extra: extra);
    }
  }
}
