// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class MarketplaceError extends AppException {
  MarketplaceErrorCode code;

  @override
  String message;

  MarketplaceError({
    required this.code,
    required this.message,
  });
}

enum MarketplaceErrorCode {
  DB_ERROR,
  CREATE_MARKETPLACE_ERROR,
  UPLOAD_IMAGES_ERROR,
  UPDATE_MARKETPLACE_ERROR,
  GET_MARKETPLACES_ERROR,
  GET_MARKETPLACE_CATEGORIES_ERROR,
  GET_SINGLE_FILTERED_MARKETPLACES_ERROR,
  GET_MULTIPLE_FILTERED_MARKETPLACES_ERROR,
  GET_USER_MARKETPLACES_ERROR,
  UPDATE_LIKE_STATUS_ERROR,
  GET_USER_LIKED_MARKETPLACES_ERROR,
  CHANGE_AVAILABILITY_STATUS_ERROR,
  DELETE_MARKETPLACE_ERROR,
  UNKNOWN_ERROR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class CreateMarketplaceError extends MarketplaceError {
  String extra;

  CreateMarketplaceError({required this.extra})
      : super(
          code: MarketplaceErrorCode.CREATE_MARKETPLACE_ERROR,
          message: 'Failed to create marketplace',
        );
}

class UploadImagesError extends MarketplaceError {
  String extra;

  UploadImagesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.UPLOAD_IMAGES_ERROR,
          message: 'Failed to upload images',
        );
}

class UpdateMarketplaceError extends MarketplaceError {
  String extra;

  UpdateMarketplaceError({required this.extra})
      : super(
          code: MarketplaceErrorCode.UPDATE_MARKETPLACE_ERROR,
          message: 'Failed to update marketplace',
        );
}

class GetMarketplacesError extends MarketplaceError {
  String extra;

  GetMarketplacesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.GET_MARKETPLACES_ERROR,
          message: 'Failed to get marketplaces',
        );
}

class GetMarketplaceCategoriesError extends MarketplaceError {
  String extra;

  GetMarketplaceCategoriesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.GET_MARKETPLACE_CATEGORIES_ERROR,
          message: 'Failed to get marketplace categories',
        );
}

class GetSingleFilteredMarketplacesError extends MarketplaceError {
  String extra;

  GetSingleFilteredMarketplacesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.GET_SINGLE_FILTERED_MARKETPLACES_ERROR,
          message: 'Failed to get single filtered marketplaces',
        );
}

class GetMultipleFilteredMarketplacesError extends MarketplaceError {
  String extra;

  GetMultipleFilteredMarketplacesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.GET_MULTIPLE_FILTERED_MARKETPLACES_ERROR,
          message: 'Failed to get multiple filtered marketplaces',
        );
}

class GetUserMarketplacesError extends MarketplaceError {
  String extra;

  GetUserMarketplacesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.GET_USER_MARKETPLACES_ERROR,
          message: 'Failed to get user marketplaces',
        );
}

class UpdateLikeStatusError extends MarketplaceError {
  String extra;

  UpdateLikeStatusError({required this.extra})
      : super(
          code: MarketplaceErrorCode.UPDATE_LIKE_STATUS_ERROR,
          message: 'Failed to update like status',
        );
}

class GetUserLikedMarketplacesError extends MarketplaceError {
  String extra;

  GetUserLikedMarketplacesError({required this.extra})
      : super(
          code: MarketplaceErrorCode.GET_USER_LIKED_MARKETPLACES_ERROR,
          message: 'Failed to get user liked marketplaces',
        );
}

class ChangeAvailabilityStatusError extends MarketplaceError {
  String extra;

  ChangeAvailabilityStatusError({required this.extra})
      : super(
          code: MarketplaceErrorCode.CHANGE_AVAILABILITY_STATUS_ERROR,
          message: 'Failed to change availability status',
        );
}

class DeleteUserMarketplaceError extends MarketplaceError {
  String extra;

  DeleteUserMarketplaceError({required this.extra})
      : super(
          code: MarketplaceErrorCode.DELETE_MARKETPLACE_ERROR,
          message: 'Failed to delete user marketplace',
        );
}

class MarketplaceDBError extends MarketplaceError {
  String extra;

  MarketplaceDBError({required this.extra})
      : super(
          code: MarketplaceErrorCode.DB_ERROR,
          message: 'Error occurred while processing the request',
        );
}

class UnknownMarketplaceError extends MarketplaceError {
  String extra;

  UnknownMarketplaceError({required this.extra})
      : super(
          code: MarketplaceErrorCode.CREATE_MARKETPLACE_ERROR,
          message: 'Unknown marketplace error',
        );
}

class MarketplaceErrorFactory {
  static MarketplaceError fromCode(
    MarketplaceErrorCode code, {
    String extra = '',
  }) {
    switch (code) {
      case MarketplaceErrorCode.DB_ERROR:
        return MarketplaceDBError(extra: extra);
      case MarketplaceErrorCode.CREATE_MARKETPLACE_ERROR:
        return CreateMarketplaceError(extra: extra);
      case MarketplaceErrorCode.UPLOAD_IMAGES_ERROR:
        return UploadImagesError(extra: extra);
      case MarketplaceErrorCode.UPDATE_MARKETPLACE_ERROR:
        return UpdateMarketplaceError(extra: extra);
      case MarketplaceErrorCode.GET_MARKETPLACES_ERROR:
        return GetMarketplacesError(extra: extra);
      case MarketplaceErrorCode.GET_MARKETPLACE_CATEGORIES_ERROR:
        return GetMarketplaceCategoriesError(extra: extra);
      case MarketplaceErrorCode.GET_SINGLE_FILTERED_MARKETPLACES_ERROR:
        return GetSingleFilteredMarketplacesError(extra: extra);
      case MarketplaceErrorCode.GET_MULTIPLE_FILTERED_MARKETPLACES_ERROR:
        return GetMultipleFilteredMarketplacesError(extra: extra);
      case MarketplaceErrorCode.GET_USER_MARKETPLACES_ERROR:
        return GetUserMarketplacesError(extra: extra);
      case MarketplaceErrorCode.UPDATE_LIKE_STATUS_ERROR:
        return UpdateLikeStatusError(extra: extra);
      case MarketplaceErrorCode.GET_USER_LIKED_MARKETPLACES_ERROR:
        return GetUserLikedMarketplacesError(extra: extra);
      case MarketplaceErrorCode.CHANGE_AVAILABILITY_STATUS_ERROR:
        return ChangeAvailabilityStatusError(extra: extra);
      case MarketplaceErrorCode.DELETE_MARKETPLACE_ERROR:
        return DeleteUserMarketplaceError(extra: extra);
      default:
        return UnknownMarketplaceError(extra: extra);
    }
  }
}
