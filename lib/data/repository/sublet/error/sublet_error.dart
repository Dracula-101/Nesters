// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class SubletError extends AppException {
  SubletErrorCode code;

  @override
  String message;

  SubletError({
    required this.code,
    required this.message,
  });
}

enum SubletErrorCode {
  DB_ERROR,
  CREATE_SUBLET_ERROR,
  UPLOAD_IMAGES_ERROR,
  GET_SUBLETS_ERROR,
  FILTER_SUBLET_ERROR,
  GET_SUBLET_LIKE_STATUS_ERROR,
  UPDATE_LIKE_STATUS_ERROR,
  GET_USER_LIKED_SUBLETS_ERROR,
  CHANGE_SUBLET_AVAILABILITY_STATUS_ERROR,
  DELETE_SUBLET_ERROR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class SubletDBError extends SubletError {
  String extra;

  SubletDBError({required this.extra})
      : super(
          code: SubletErrorCode.DB_ERROR,
          message: 'Database error',
        );
}

class CreateSubletError extends SubletError {
  String extra;

  CreateSubletError({required this.extra})
      : super(
          code: SubletErrorCode.CREATE_SUBLET_ERROR,
          message: 'Failed to create sublet',
        );
}

class UploadImagesError extends SubletError {
  String extra;

  UploadImagesError({required this.extra})
      : super(
          code: SubletErrorCode.UPLOAD_IMAGES_ERROR,
          message: 'Failed to upload images',
        );
}

class GetSubletsError extends SubletError {
  String extra;

  GetSubletsError({required this.extra})
      : super(
          code: SubletErrorCode.GET_SUBLETS_ERROR,
          message: 'Failed to get sublets',
        );
}

class FilterSubletError extends SubletError {
  String extra;

  FilterSubletError({required this.extra})
      : super(
          code: SubletErrorCode.FILTER_SUBLET_ERROR,
          message: 'Failed to filter sublets',
        );
}

class GetSubletLikeStatusError extends SubletError {
  String extra;

  GetSubletLikeStatusError({required this.extra})
      : super(
          code: SubletErrorCode.GET_SUBLET_LIKE_STATUS_ERROR,
          message: 'Failed to get sublet like status',
        );
}

class UpdateLikeStatusError extends SubletError {
  String extra;

  UpdateLikeStatusError({required this.extra})
      : super(
          code: SubletErrorCode.UPDATE_LIKE_STATUS_ERROR,
          message: 'Failed to update like status',
        );
}

class GetUserLikedSubletsError extends SubletError {
  String extra;

  GetUserLikedSubletsError({required this.extra})
      : super(
          code: SubletErrorCode.GET_USER_LIKED_SUBLETS_ERROR,
          message: 'Failed to get user liked sublets',
        );
}

class ChangeSubletAvailabilityStatusError extends SubletError {
  String extra;

  ChangeSubletAvailabilityStatusError({required this.extra})
      : super(
          code: SubletErrorCode.CHANGE_SUBLET_AVAILABILITY_STATUS_ERROR,
          message: 'Failed to change sublet availability status',
        );
}

class DeleteUserSubletError extends SubletError {
  String extra;

  DeleteUserSubletError({required this.extra})
      : super(
          code: SubletErrorCode.DELETE_SUBLET_ERROR,
          message: 'Failed to delete user sublet',
        );
}

class UnknownSubletError extends SubletError {
  String extra;

  UnknownSubletError({required this.extra})
      : super(
          code: SubletErrorCode.CREATE_SUBLET_ERROR,
          message: 'An unknown error occurred',
        );
}

class SubletErrorFactory {
  static SubletError createSubletError(SubletErrorCode code, String extra) {
    switch (code) {
      case SubletErrorCode.DB_ERROR:
        return SubletDBError(extra: extra);
      case SubletErrorCode.CREATE_SUBLET_ERROR:
        return CreateSubletError(extra: extra);
      case SubletErrorCode.UPLOAD_IMAGES_ERROR:
        return UploadImagesError(extra: extra);
      case SubletErrorCode.GET_SUBLETS_ERROR:
        return GetSubletsError(extra: extra);
      case SubletErrorCode.FILTER_SUBLET_ERROR:
        return FilterSubletError(extra: extra);
      case SubletErrorCode.GET_SUBLET_LIKE_STATUS_ERROR:
        return GetSubletLikeStatusError(extra: extra);
      case SubletErrorCode.GET_USER_LIKED_SUBLETS_ERROR:
        return GetUserLikedSubletsError(extra: extra);
      case SubletErrorCode.UPDATE_LIKE_STATUS_ERROR:
        return UpdateLikeStatusError(extra: extra);
      case SubletErrorCode.CHANGE_SUBLET_AVAILABILITY_STATUS_ERROR:
        return ChangeSubletAvailabilityStatusError(extra: extra);
      case SubletErrorCode.DELETE_SUBLET_ERROR:
        return DeleteUserSubletError(extra: extra);
      default:
        return UnknownSubletError(extra: extra);
    }
  }
}
