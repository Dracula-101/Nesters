// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class SubletError extends AppException {
  SubletErrorCode code;

  @override
  String message;
  String? extra;

  SubletError({
    required this.code,
    required this.message,
    this.extra,
  });
}

enum SubletErrorCode {
  DB_ERR,
  CREATE_SUBLET_ERR,
  UPLOAD_IMAGES_ERR,
  GET_SUBLETS_ERR,
  FILTER_SUBLET_ERR,
  GET_SUBLET_LIKE_STATUS_ERR,
  UPDATE_LIKE_STATUS_ERR,
  GET_USER_LIKED_SUBLETS_ERR,
  CHANGE_SUBLET_AVAILABILITY_STATUS_ERR,
  DELETE_SUBLET_ERR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class SubletDBError extends SubletError {
  SubletDBError({required String extra})
      : super(
          code: SubletErrorCode.DB_ERR,
          message: 'Database error',
          extra: extra,
        );
}

class CreateSubletError extends SubletError {
  CreateSubletError({required String extra})
      : super(
            code: SubletErrorCode.CREATE_SUBLET_ERR,
            message: 'Failed to create sublet',
            extra: extra);
}

class UploadImagesError extends SubletError {
  UploadImagesError({required String extra})
      : super(
            code: SubletErrorCode.UPLOAD_IMAGES_ERR,
            message: 'Failed to upload images',
            extra: extra);
}

class GetSubletsError extends SubletError {
  GetSubletsError({required String extra})
      : super(
            code: SubletErrorCode.GET_SUBLETS_ERR,
            message: 'Failed to get sublets',
            extra: extra);
}

class FilterSubletError extends SubletError {
  FilterSubletError({required String extra})
      : super(
            code: SubletErrorCode.FILTER_SUBLET_ERR,
            message: 'Failed to filter sublets',
            extra: extra);
}

class GetSubletLikeStatusError extends SubletError {
  GetSubletLikeStatusError({required String extra})
      : super(
            code: SubletErrorCode.GET_SUBLET_LIKE_STATUS_ERR,
            message: 'Failed to get sublet like status',
            extra: extra);
}

class UpdateLikeStatusError extends SubletError {
  UpdateLikeStatusError({required String extra})
      : super(
            code: SubletErrorCode.UPDATE_LIKE_STATUS_ERR,
            message: 'Failed to update like status',
            extra: extra);
}

class GetUserLikedSubletsError extends SubletError {
  GetUserLikedSubletsError({required String extra})
      : super(
            code: SubletErrorCode.GET_USER_LIKED_SUBLETS_ERR,
            message: 'Failed to get user liked sublets',
            extra: extra);
}

class ChangeSubletAvailabilityStatusError extends SubletError {
  ChangeSubletAvailabilityStatusError({required String extra})
      : super(
            code: SubletErrorCode.CHANGE_SUBLET_AVAILABILITY_STATUS_ERR,
            message: 'Failed to change sublet availability status',
            extra: extra);
}

class DeleteUserSubletError extends SubletError {
  DeleteUserSubletError({required String extra})
      : super(
            code: SubletErrorCode.DELETE_SUBLET_ERR,
            message: 'Failed to delete user sublet',
            extra: extra);
}

class UnknownSubletError extends SubletError {
  UnknownSubletError({required String extra})
      : super(
            code: SubletErrorCode.CREATE_SUBLET_ERR,
            message: 'An error occurred',
            extra: extra);
}

class SubletErrorFactory {
  static SubletError createSubletError(SubletErrorCode code, String extra) {
    switch (code) {
      case SubletErrorCode.DB_ERR:
        return SubletDBError(extra: extra);
      case SubletErrorCode.CREATE_SUBLET_ERR:
        return CreateSubletError(extra: extra);
      case SubletErrorCode.UPLOAD_IMAGES_ERR:
        return UploadImagesError(extra: extra);
      case SubletErrorCode.GET_SUBLETS_ERR:
        return GetSubletsError(extra: extra);
      case SubletErrorCode.FILTER_SUBLET_ERR:
        return FilterSubletError(extra: extra);
      case SubletErrorCode.GET_SUBLET_LIKE_STATUS_ERR:
        return GetSubletLikeStatusError(extra: extra);
      case SubletErrorCode.GET_USER_LIKED_SUBLETS_ERR:
        return GetUserLikedSubletsError(extra: extra);
      case SubletErrorCode.UPDATE_LIKE_STATUS_ERR:
        return UpdateLikeStatusError(extra: extra);
      case SubletErrorCode.CHANGE_SUBLET_AVAILABILITY_STATUS_ERR:
        return ChangeSubletAvailabilityStatusError(extra: extra);
      case SubletErrorCode.DELETE_SUBLET_ERR:
        return DeleteUserSubletError(extra: extra);
      default:
        return UnknownSubletError(extra: extra);
    }
  }
}
