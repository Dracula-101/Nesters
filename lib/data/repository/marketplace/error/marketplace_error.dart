// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class MarketplaceError extends AppException {
  MarketplaceErrorCode code;

  @override
  String message;
  String? hint;

  MarketplaceError({
    required this.code,
    required this.message,
    this.hint,
  });
}

enum MarketplaceErrorCode {
  DB_ERR,
  CREATE_MARKETPLACE_ERR,
  UPLOAD_IMAGES_ERR,
  UPDATE_MARKETPLACE_ERR,
  GET_MARKETPLACES_ERR,
  GET_MARKETPLACE_CATEGORIES_ERR,
  GET_SINGLE_FILTERED_MARKETPLACES_ERR,
  GET_MULTIPLE_FILTERED_MARKETPLACES_ERR,
  GET_USER_MARKETPLACES_ERR,
  UPDATE_LIKE_STATUS_ERR,
  GET_USER_LIKED_MARKETPLACES_ERR,
  CHANGE_AVAILABILITY_STATUS_ERR,
  DELETE_MARKETPLACE_ERR,
  UNKNOWN_ERR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class CreateMarketplaceError extends MarketplaceError {
  CreateMarketplaceError({required String hint})
      : super(
          code: MarketplaceErrorCode.CREATE_MARKETPLACE_ERR,
          message: 'Failed to create marketplace',
          hint: hint,
        );
}

class UploadImagesError extends MarketplaceError {
  UploadImagesError({required String hint})
      : super(
          code: MarketplaceErrorCode.UPLOAD_IMAGES_ERR,
          message: 'Failed to upload images',
          hint: hint,
        );
}

class UpdateMarketplaceError extends MarketplaceError {
  UpdateMarketplaceError({required String hint})
      : super(
          code: MarketplaceErrorCode.UPDATE_MARKETPLACE_ERR,
          message: 'Failed to update marketplace',
          hint: hint,
        );
}

class GetMarketplacesError extends MarketplaceError {
  GetMarketplacesError({required String hint})
      : super(
          code: MarketplaceErrorCode.GET_MARKETPLACES_ERR,
          message: 'Failed to get marketplaces',
          hint: hint,
        );
}

class GetMarketplaceCategoriesError extends MarketplaceError {
  GetMarketplaceCategoriesError({required String hint})
      : super(
          code: MarketplaceErrorCode.GET_MARKETPLACE_CATEGORIES_ERR,
          message: 'Failed to get marketplace categories',
          hint: hint,
        );
}

class GetSingleFilteredMarketplacesError extends MarketplaceError {
  GetSingleFilteredMarketplacesError({required String hint})
      : super(
          code: MarketplaceErrorCode.GET_SINGLE_FILTERED_MARKETPLACES_ERR,
          message: 'Failed to get single filtered marketplaces',
          hint: hint,
        );
}

class GetMultipleFilteredMarketplacesError extends MarketplaceError {
  GetMultipleFilteredMarketplacesError({required String hint})
      : super(
          code: MarketplaceErrorCode.GET_MULTIPLE_FILTERED_MARKETPLACES_ERR,
          message: 'Failed to get multiple filtered marketplaces',
          hint: hint,
        );
}

class GetUserMarketplacesError extends MarketplaceError {
  GetUserMarketplacesError({required String hint})
      : super(
          code: MarketplaceErrorCode.GET_USER_MARKETPLACES_ERR,
          message: 'Failed to get user marketplaces',
          hint: hint,
        );
}

class UpdateLikeStatusError extends MarketplaceError {
  UpdateLikeStatusError({required String hint})
      : super(
          code: MarketplaceErrorCode.UPDATE_LIKE_STATUS_ERR,
          message: 'Failed to update like status',
          hint: hint,
        );
}

class GetUserLikedMarketplacesError extends MarketplaceError {
  GetUserLikedMarketplacesError({required String hint})
      : super(
          code: MarketplaceErrorCode.GET_USER_LIKED_MARKETPLACES_ERR,
          message: 'Failed to get user liked marketplaces',
          hint: hint,
        );
}

class ChangeAvailabilityStatusError extends MarketplaceError {
  ChangeAvailabilityStatusError({required String hint})
      : super(
          code: MarketplaceErrorCode.CHANGE_AVAILABILITY_STATUS_ERR,
          message: 'Failed to change availability status',
          hint: hint,
        );
}

class DeleteUserMarketplaceError extends MarketplaceError {
  DeleteUserMarketplaceError({required String hint})
      : super(
          code: MarketplaceErrorCode.DELETE_MARKETPLACE_ERR,
          message: 'Failed to delete user marketplace',
          hint: hint,
        );
}

class MarketplaceDBError extends MarketplaceError {
  MarketplaceDBError({required String hint})
      : super(
          code: MarketplaceErrorCode.DB_ERR,
          message: 'Error occurred while processing the request',
          hint: hint,
        );
}

class UnknownMarketplaceError extends MarketplaceError {
  UnknownMarketplaceError({required String hint})
      : super(
          code: MarketplaceErrorCode.CREATE_MARKETPLACE_ERR,
          message: 'Unknown marketplace error',
          hint: hint,
        );
}

class MarketplaceErrorFactory {
  static MarketplaceError fromCode(
    MarketplaceErrorCode code, {
    String hint = '',
  }) {
    switch (code) {
      case MarketplaceErrorCode.DB_ERR:
        return MarketplaceDBError(hint: hint);
      case MarketplaceErrorCode.CREATE_MARKETPLACE_ERR:
        return CreateMarketplaceError(hint: hint);
      case MarketplaceErrorCode.UPLOAD_IMAGES_ERR:
        return UploadImagesError(hint: hint);
      case MarketplaceErrorCode.UPDATE_MARKETPLACE_ERR:
        return UpdateMarketplaceError(hint: hint);
      case MarketplaceErrorCode.GET_MARKETPLACES_ERR:
        return GetMarketplacesError(hint: hint);
      case MarketplaceErrorCode.GET_MARKETPLACE_CATEGORIES_ERR:
        return GetMarketplaceCategoriesError(hint: hint);
      case MarketplaceErrorCode.GET_SINGLE_FILTERED_MARKETPLACES_ERR:
        return GetSingleFilteredMarketplacesError(hint: hint);
      case MarketplaceErrorCode.GET_MULTIPLE_FILTERED_MARKETPLACES_ERR:
        return GetMultipleFilteredMarketplacesError(hint: hint);
      case MarketplaceErrorCode.GET_USER_MARKETPLACES_ERR:
        return GetUserMarketplacesError(hint: hint);
      case MarketplaceErrorCode.UPDATE_LIKE_STATUS_ERR:
        return UpdateLikeStatusError(hint: hint);
      case MarketplaceErrorCode.GET_USER_LIKED_MARKETPLACES_ERR:
        return GetUserLikedMarketplacesError(hint: hint);
      case MarketplaceErrorCode.CHANGE_AVAILABILITY_STATUS_ERR:
        return ChangeAvailabilityStatusError(hint: hint);
      case MarketplaceErrorCode.DELETE_MARKETPLACE_ERR:
        return DeleteUserMarketplaceError(hint: hint);
      default:
        return UnknownMarketplaceError(hint: hint);
    }
  }
}
