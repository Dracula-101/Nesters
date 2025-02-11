import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class UserError implements AppException {
  UserErrorCode get errorCode;
  @override
  String get message;
}

enum UserErrorCode {
  USER_BASIC_INFO_ERR,
  CHECK_USER_DELETED_ERR,
  GET_INFO_ERR,
  UPDATE_INFO_ERR,
  UPLOAD_USER_IMAGE_ERR,
  USER_DELETE_ERR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class UserBasicInfoError implements UserError {
  @override
  String message;

  UserBasicInfoError({
    required this.message,
  });

  @override
  final UserErrorCode errorCode = UserErrorCode.USER_BASIC_INFO_ERR;
}

class CheckUserDeletedError implements UserError {
  @override
  String message;

  CheckUserDeletedError({
    required this.message,
  });

  @override
  final UserErrorCode errorCode = UserErrorCode.CHECK_USER_DELETED_ERR;
}

class GetUserInfoError implements UserError {
  @override
  String message;

  GetUserInfoError({
    required this.message,
  });

  @override
  final UserErrorCode errorCode = UserErrorCode.GET_INFO_ERR;
}

class UpdateUserInfoError implements UserError {
  @override
  String message;

  UpdateUserInfoError({
    required this.message,
  });

  @override
  final UserErrorCode errorCode = UserErrorCode.UPDATE_INFO_ERR;
}

class UploadUserImageError implements UserError {
  @override
  String message;

  UploadUserImageError({
    required this.message,
  });

  @override
  final UserErrorCode errorCode = UserErrorCode.UPLOAD_USER_IMAGE_ERR;
}

class UserDeleteError implements UserError {
  @override
  String message;

  UserDeleteError({
    required this.message,
  });

  @override
  final UserErrorCode errorCode = UserErrorCode.USER_DELETE_ERR;
}
