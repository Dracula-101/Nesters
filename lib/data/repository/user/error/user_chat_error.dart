// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

enum UserChatErrorCode {
  CHAT_GET_MSG_ERROR,
  CHAT_ADD_MSG_ERROR,
  CHAT_ROOM_CREATE_ERROR,
  CHAT_ROOM_EXIST_ERROR,
  CHAT_UPLOAD_DOC_ERROR,
  CHAT_DOWNLOAD_DOC_ERROR,
  TOKEN_CHANGE_LISTENER_ERROR,

  GET_PROFILE_ERROR,
  GET_SENT_REQ_ERROR,
  GET_RECEIVED_REQ_ERROR,
  SEND_REQ_ERROR,
  ACCEPT_REQ_ERROR,
  REJECT_REQ_ERROR,
  DELETE_USER_ERROR,
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
          code: UserChatErrorCode.CHAT_GET_MSG_ERROR,
          message: 'Failed to get messages',
        );
}

class ChatAddMsgError extends UserChatError {
  String extra;

  ChatAddMsgError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_ADD_MSG_ERROR,
          message: 'Failed to add message',
        );
}

class ChatRoomCreateError extends UserChatError {
  String extra;

  ChatRoomCreateError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_ROOM_CREATE_ERROR,
          message: 'Failed to create chat room',
        );
}

class ChatRoomExistError extends UserChatError {
  String extra;

  ChatRoomExistError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_ROOM_EXIST_ERROR,
          message: 'Chat room already exists',
        );
}

class ChatUploadDocError extends UserChatError {
  String extra;

  ChatUploadDocError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_UPLOAD_DOC_ERROR,
          message: 'Failed to upload document',
        );
}

class ChatDownloadDocError extends UserChatError {
  String extra;

  ChatDownloadDocError({required this.extra})
      : super(
          code: UserChatErrorCode.CHAT_DOWNLOAD_DOC_ERROR,
          message: 'Failed to download document',
        );
}

class ChatTokenChangeListenerError extends UserChatError {
  String extra;

  ChatTokenChangeListenerError({required this.extra})
      : super(
          code: UserChatErrorCode.TOKEN_CHANGE_LISTENER_ERROR,
          message: 'Failed to change token listener',
        );
}

class GetProfileError extends UserChatError {
  String extra;

  GetProfileError({required this.extra})
      : super(
          code: UserChatErrorCode.GET_PROFILE_ERROR,
          message: 'Failed to get profile',
        );
}

class GetSentReqError extends UserChatError {
  String extra;

  GetSentReqError({required this.extra})
      : super(
          code: UserChatErrorCode.GET_SENT_REQ_ERROR,
          message: 'Failed to get sent requests',
        );
}

class GetReceivedReqError extends UserChatError {
  String extra;

  GetReceivedReqError({required this.extra})
      : super(
          code: UserChatErrorCode.GET_RECEIVED_REQ_ERROR,
          message: 'Failed to get received requests',
        );
}

class SendReqError extends UserChatError {
  String extra;

  SendReqError({required this.extra})
      : super(
          code: UserChatErrorCode.SEND_REQ_ERROR,
          message: 'Failed to send request',
        );
}

class AcceptReqError extends UserChatError {
  String extra;

  AcceptReqError({required this.extra})
      : super(
          code: UserChatErrorCode.ACCEPT_REQ_ERROR,
          message: 'Failed to accept request',
        );
}

class RejectReqError extends UserChatError {
  String extra;

  RejectReqError({required this.extra})
      : super(
          code: UserChatErrorCode.REJECT_REQ_ERROR,
          message: 'Failed to reject request',
        );
}

class DeleteUserError extends UserChatError {
  String extra;

  DeleteUserError({required this.extra})
      : super(
          code: UserChatErrorCode.DELETE_USER_ERROR,
          message: 'Failed to delete user',
        );
}

class UserChatErrorFactory {
  static UserChatError create(UserChatErrorCode code, String extra) {
    switch (code) {
      case UserChatErrorCode.CHAT_GET_MSG_ERROR:
        return ChatGetMsgError(extra: extra);
      case UserChatErrorCode.CHAT_ADD_MSG_ERROR:
        return ChatAddMsgError(extra: extra);
      case UserChatErrorCode.CHAT_ROOM_CREATE_ERROR:
        return ChatRoomCreateError(extra: extra);
      case UserChatErrorCode.CHAT_ROOM_EXIST_ERROR:
        return ChatRoomExistError(extra: extra);
      case UserChatErrorCode.CHAT_UPLOAD_DOC_ERROR:
        return ChatUploadDocError(extra: extra);
      case UserChatErrorCode.CHAT_DOWNLOAD_DOC_ERROR:
        return ChatDownloadDocError(extra: extra);
      case UserChatErrorCode.TOKEN_CHANGE_LISTENER_ERROR:
        return ChatTokenChangeListenerError(extra: extra);
      case UserChatErrorCode.GET_PROFILE_ERROR:
        return GetProfileError(extra: extra);
      case UserChatErrorCode.GET_SENT_REQ_ERROR:
        return GetSentReqError(extra: extra);
      case UserChatErrorCode.GET_RECEIVED_REQ_ERROR:
        return GetReceivedReqError(extra: extra);
      case UserChatErrorCode.SEND_REQ_ERROR:
        return SendReqError(extra: extra);
      case UserChatErrorCode.ACCEPT_REQ_ERROR:
        return AcceptReqError(extra: extra);
      case UserChatErrorCode.REJECT_REQ_ERROR:
        return RejectReqError(extra: extra);
      case UserChatErrorCode.DELETE_USER_ERROR:
        return DeleteUserError(extra: extra);
    }
  }
}
