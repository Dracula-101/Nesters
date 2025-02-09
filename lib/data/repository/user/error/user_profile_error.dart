// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

enum UserChatProfileErrorCode {
  GET_PROFILE_ERROR,
  GET_SENT_REQ_ERROR,
  GET_RECEIVED_REQ_ERROR,
  SEND_REQ_ERROR,
  CREATE_CHAT_ROOM_ERROR,
  ACCEPT_REQ_ERROR,
  REJECT_REQ_ERROR,
  DELETE_USER_ERROR,
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
          code: UserChatProfileErrorCode.GET_PROFILE_ERROR,
          message: 'Failed to get profile',
        );
}

class GetSentReqError extends UserChatProfileError {
  String extra;

  GetSentReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.GET_SENT_REQ_ERROR,
          message: 'Failed to get sent requests',
        );
}

class GetReceivedReqError extends UserChatProfileError {
  String extra;

  GetReceivedReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.GET_RECEIVED_REQ_ERROR,
          message: 'Failed to get received requests',
        );
}

class CreateChatRoomError extends UserChatProfileError {
  String extra;

  CreateChatRoomError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.CREATE_CHAT_ROOM_ERROR,
          message: 'Failed to create chat room',
        );
}

class SendReqError extends UserChatProfileError {
  String extra;

  SendReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.SEND_REQ_ERROR,
          message: 'Failed to send request',
        );
}

class AcceptReqError extends UserChatProfileError {
  String extra;

  AcceptReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.ACCEPT_REQ_ERROR,
          message: 'Failed to accept request',
        );
}

class RejectReqError extends UserChatProfileError {
  String extra;

  RejectReqError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.REJECT_REQ_ERROR,
          message: 'Failed to reject request',
        );
}

class DeleteUserError extends UserChatProfileError {
  String extra;

  DeleteUserError({required this.extra})
      : super(
          code: UserChatProfileErrorCode.DELETE_USER_ERROR,
          message: 'Failed to delete user',
        );
}

class UserChatProfileErrorFactory {
  static UserChatProfileError create(
      UserChatProfileErrorCode code, String extra) {
    switch (code) {
      case UserChatProfileErrorCode.GET_PROFILE_ERROR:
        return GetProfileError(extra: extra);
      case UserChatProfileErrorCode.GET_SENT_REQ_ERROR:
        return GetSentReqError(extra: extra);
      case UserChatProfileErrorCode.GET_RECEIVED_REQ_ERROR:
        return GetReceivedReqError(extra: extra);
      case UserChatProfileErrorCode.SEND_REQ_ERROR:
        return SendReqError(extra: extra);
      case UserChatProfileErrorCode.ACCEPT_REQ_ERROR:
        return AcceptReqError(extra: extra);
      case UserChatProfileErrorCode.REJECT_REQ_ERROR:
        return RejectReqError(extra: extra);
      case UserChatProfileErrorCode.DELETE_USER_ERROR:
        return DeleteUserError(extra: extra);
      case UserChatProfileErrorCode.CREATE_CHAT_ROOM_ERROR:
        return CreateChatRoomError(extra: extra);
    }
  }
}
