// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class ApartmentError extends AppException {
  ApartmentErrorCode code;

  @override
  String message;

  ApartmentError({
    required this.code,
    required this.message,
  });
}

enum ApartmentErrorCode {
  DB_ERR,
  CREATE_APARTMENT_ERR,
  UPDATE_APARTMENT_ERR,
  UPLOAD_IMAGES_ERR,
  GET_APARTMENTS_ERR,
  FILTER_APARTMENT_ERR,
  GET_APARTMENT_LIKE_STATUS_ERR,
  UPDATE_LIKE_STATUS_ERR,
  GET_USER_LIKED_APARTMENTS_ERR,
  CHANGE_APARTMENT_AVAILABILITY_STATUS_ERR,
  DELETE_APARTMENT_ERR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class ApartmentDBError extends ApartmentError {
  String extra;

  ApartmentDBError({required this.extra})
      : super(
          code: ApartmentErrorCode.DB_ERR,
          message: 'Database error',
        );
}

class CreateApartmentError extends ApartmentError {
  String extra;

  CreateApartmentError({required this.extra})
      : super(
          code: ApartmentErrorCode.CREATE_APARTMENT_ERR,
          message: 'Failed to create apartment',
        );
}

class UpdateApartmentError extends ApartmentError {
  String extra;

  UpdateApartmentError({required this.extra})
      : super(
          code: ApartmentErrorCode.UPDATE_APARTMENT_ERR,
          message: 'Failed to update apartment',
        );
}

class UploadImagesError extends ApartmentError {
  String extra;

  UploadImagesError({required this.extra})
      : super(
          code: ApartmentErrorCode.UPLOAD_IMAGES_ERR,
          message: 'Failed to upload images',
        );
}

class GetApartmentsError extends ApartmentError {
  String extra;

  GetApartmentsError({required this.extra})
      : super(
          code: ApartmentErrorCode.GET_APARTMENTS_ERR,
          message: 'Failed to get apartment',
        );
}

class FilterApartmentError extends ApartmentError {
  String extra;

  FilterApartmentError({required this.extra})
      : super(
          code: ApartmentErrorCode.FILTER_APARTMENT_ERR,
          message: 'Failed to filter apartment',
        );
}

class GetApartmentLikeStatusError extends ApartmentError {
  String extra;

  GetApartmentLikeStatusError({required this.extra})
      : super(
          code: ApartmentErrorCode.GET_APARTMENT_LIKE_STATUS_ERR,
          message: 'Failed to get apartment like status',
        );
}

class UpdateLikeStatusError extends ApartmentError {
  String extra;

  UpdateLikeStatusError({required this.extra})
      : super(
          code: ApartmentErrorCode.UPDATE_LIKE_STATUS_ERR,
          message: 'Failed to apartment like status',
        );
}

class GetUserLikedApartmentsError extends ApartmentError {
  String extra;

  GetUserLikedApartmentsError({required this.extra})
      : super(
          code: ApartmentErrorCode.GET_USER_LIKED_APARTMENTS_ERR,
          message: 'Failed to get user liked apartments',
        );
}

class ChangeApartmentAvailabilityStatusError extends ApartmentError {
  String extra;

  ChangeApartmentAvailabilityStatusError({required this.extra})
      : super(
          code: ApartmentErrorCode.CHANGE_APARTMENT_AVAILABILITY_STATUS_ERR,
          message: 'Failed to change apartment availability status',
        );
}

class DeleteUserApartmentError extends ApartmentError {
  String extra;

  DeleteUserApartmentError({required this.extra})
      : super(
          code: ApartmentErrorCode.DELETE_APARTMENT_ERR,
          message: 'Failed to delete user apartment',
        );
}

class UnknownApartmentError extends ApartmentError {
  String extra;

  UnknownApartmentError({required this.extra})
      : super(
          code: ApartmentErrorCode.CREATE_APARTMENT_ERR,
          message: 'An unknown error occurred',
        );
}

class ApartmentErrorFactory {
  static ApartmentError createApartmentError(
      ApartmentErrorCode code, String extra) {
    switch (code) {
      case ApartmentErrorCode.DB_ERR:
        return ApartmentDBError(extra: extra);
      case ApartmentErrorCode.CREATE_APARTMENT_ERR:
        return CreateApartmentError(extra: extra);
      case ApartmentErrorCode.UPDATE_APARTMENT_ERR:
        return UpdateApartmentError(extra: extra);
      case ApartmentErrorCode.UPLOAD_IMAGES_ERR:
        return UploadImagesError(extra: extra);
      case ApartmentErrorCode.GET_APARTMENTS_ERR:
        return GetApartmentsError(extra: extra);
      case ApartmentErrorCode.FILTER_APARTMENT_ERR:
        return FilterApartmentError(extra: extra);
      case ApartmentErrorCode.GET_APARTMENT_LIKE_STATUS_ERR:
        return GetApartmentLikeStatusError(extra: extra);
      case ApartmentErrorCode.GET_USER_LIKED_APARTMENTS_ERR:
        return GetUserLikedApartmentsError(extra: extra);
      case ApartmentErrorCode.UPDATE_LIKE_STATUS_ERR:
        return UpdateLikeStatusError(extra: extra);
      case ApartmentErrorCode.CHANGE_APARTMENT_AVAILABILITY_STATUS_ERR:
        return ChangeApartmentAvailabilityStatusError(extra: extra);
      case ApartmentErrorCode.DELETE_APARTMENT_ERR:
        return DeleteUserApartmentError(extra: extra);
      default:
        return UnknownApartmentError(extra: extra);
    }
  }
}
