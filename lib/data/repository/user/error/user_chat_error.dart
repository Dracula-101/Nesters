// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

enum UserChatErrorCode {
  CHAT_GET_MSG_ERR,
  CHAT_ADD_MSG_ERR,
  CHAT_ROOM_CREATE_ERR,
  CHAT_ROOM_EXIST_ERR,
  CHAT_UPLOAD_DOC_ERR,
  CHAT_DOWNLOAD_DOC_ERR,
  TOKEN_CHANGE_LISTENER_ERR,

  GET_PROFILE_ERR,
  GET_SENT_REQ_ERR,
  GET_RECEIVED_REQ_ERR,
  SEND_REQ_ERR,
  ACCEPT_REQ_ERR,
  REJECT_REQ_ERR,
  DELETE_USER_ERR,
}

abstract class UserChatError extends AppException {
  UserChatErrorCode code;

  @override
  String message;

  UserChatError({
    required this.code,
    required this.message,
  });
}

class ChatGetMsgError extends UserChatError {
  String extra;

  ChatGetMsgError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_GET_MSG_ERR,
          message: 'Failed to get messages',
        );
}

class ChatAddMsgError extends UserChatError {
  String extra;

  ChatAddMsgError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_ADD_MSG_ERR,
          message: 'Failed to add message',
        );
}

class ChatRoomCreateError extends UserChatError {
  String extra;

  ChatRoomCreateError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_ROOM_CREATE_ERR,
          message: 'Failed to create chat room',
        );
}

class ChatRoomExistError extends UserChatError {
  String extra;

  ChatRoomExistError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_ROOM_EXIST_ERR,
          message: 'Chat room already exists',
        );
}

class ChatUploadDocError extends UserChatError {
  String extra;

  ChatUploadDocError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_UPLOAD_DOC_ERR,
          message: 'Failed to upload document',
        );
}

class ChatDownloadDocError extends UserChatError {
  String extra;

  ChatDownloadDocError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_DOWNLOAD_DOC_ERR,
          message: 'Failed to download document',
        );
}

class ChatTokenChangeListenerError extends UserChatError {
  String extra;

  ChatTokenChangeListenerError({required this.extra})
      : super(
          code: UserChatErrorCode.TOKEN_CHANGE_LISTENER_ERR,
          message: 'Failed to change token listener',
        );
}

class GetProfileError extends UserChatError {
  String extra;

  GetProfileError({required this.extra})
      : super(
          code: UserChatErrorCode.GET_PROFILE_ERR,
          message: 'Failed to get profile',
        );
}

class GetSentReqError extends UserChatError {
  String extra;

  GetSentReqError({required this.extra})
      : super(
          code: UserChatErrorCode.GET_SENT_REQ_ERR,
          message: 'Failed to get sent requests',
        );
}

class GetReceivedReqError extends UserChatError {
  String extra;

  GetReceivedReqError({required this.extra})
      : super(
          code: UserChatErrorCode.GET_RECEIVED_REQ_ERR,
          message: 'Failed to get received requests',
        );
}

class SendReqError extends UserChatError {
  String extra;

  SendReqError({required this.extra})
      : super(
          code: UserChatErrorCode.SEND_REQ_ERR,
          message: 'Failed to send request',
        );
}

class AcceptReqError extends UserChatError {
  String extra;

  AcceptReqError({required this.extra})
      : super(
          code: UserChatErrorCode.ACCEPT_REQ_ERR,
          message: 'Failed to accept request',
        );
}

class RejectReqError extends UserChatError {
  String extra;

  RejectReqError({required this.extra})
      : super(
          code: UserChatErrorCode.REJECT_REQ_ERR,
          message: 'Failed to reject request',
        );
}

class DeleteUserError extends UserChatError {
  String extra;

  DeleteUserError({required this.extra})
      : super(
          code: UserChatErrorCode.DELETE_USER_ERR,
          message: 'Failed to delete user',
        );
}

class UserChatErrorFactory {
  static UserChatError create(UserChatErrorCode code, String extra) {
    switch (code) {
      case UserChatErrorCode.CHAT_GET_MSG_ERR:
        return ChatGetMsgError(extra: extra);
      case UserChatErrorCode.CHAT_ADD_MSG_ERR:
        return ChatAddMsgError(extra: extra);
      case UserChatErrorCode.CHAT_ROOM_CREATE_ERR:
        return ChatRoomCreateError(extra: extra);
      case UserChatErrorCode.CHAT_ROOM_EXIST_ERR:
        return ChatRoomExistError(extra: extra);
      case UserChatErrorCode.CHAT_UPLOAD_DOC_ERR:
        return ChatUploadDocError(extra: extra);
      case UserChatErrorCode.CHAT_DOWNLOAD_DOC_ERR:
        return ChatDownloadDocError(extra: extra);
      case UserChatErrorCode.TOKEN_CHANGE_LISTENER_ERR:
        return ChatTokenChangeListenerError(extra: extra);
      case UserChatErrorCode.GET_PROFILE_ERR:
        return GetProfileError(extra: extra);
      case UserChatErrorCode.GET_SENT_REQ_ERR:
        return GetSentReqError(extra: extra);
      case UserChatErrorCode.GET_RECEIVED_REQ_ERR:
        return GetReceivedReqError(extra: extra);
      case UserChatErrorCode.SEND_REQ_ERR:
        return SendReqError(extra: extra);
      case UserChatErrorCode.ACCEPT_REQ_ERR:
        return AcceptReqError(extra: extra);
      case UserChatErrorCode.REJECT_REQ_ERR:
        return RejectReqError(extra: extra);
      case UserChatErrorCode.DELETE_USER_ERR:
        return DeleteUserError(extra: extra);
    }
  }
}
