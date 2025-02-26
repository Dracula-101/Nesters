import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:google_places_sdk/google_places_sdk.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/marketplace/error/marketplace_error.dart';
import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_link_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_period_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'marketplace_form_state.dart';

class MarketplaceFormCubit extends Cubit<MarketplaceFormState> {
  MarketplaceFormCubit({
    MarketplaceModel? marketplaceModel,
  }) : super(MarketplaceFormState(
          item: marketplaceModel,
          hasSecondPageAccess: kDebugMode,
        )) {
    loadMarketplaceCategories();
    if (marketplaceModel != null) {
      emit(state.copyWith(hasSecondPageAccess: true, isPreFilled: true));
    }
  }

  final MarketplaceRepository _marketplaceRepository =
      GetIt.I<MarketplaceRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final GooglePlaces _googlePlaces = GetIt.I<GooglePlaces>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  int itemId = DateTime.now().millisecondsSinceEpoch;

  void validatePage() {
    emit(state.copyWith(isValidating: false));
    emit(state.copyWith(isValidating: true));
  }

  void addPlaceId(String placeId) {
    emit(state.copyWith(placeId: placeId));
  }

  void onPageChange(int pageNumber) {
    emit(state.copyWith(pageNumber: pageNumber, isValidating: false));
  }

  void showPageValid(int page) {
    if (page == 1) {
      emit(state.copyWith(hasSecondPageAccess: true));
    }
  }

  void addFirstPageData({
    required String name,
    required String address,
    required DateTime? startDate,
    required DateTime? endDate,
    required String description,
    required double itemPrice,
    required MarketplaceCategoryModel? category,
    required MarketplaceLinkModel? link,
  }) {
    MarketplaceModel? model = MarketplaceModel(
      id: state.item?.id ?? itemId,
      name: name,
      address: address,
      period: MarketplacePeriodModel(
        periodFrom: startDate,
        periodTill: endDate,
      ),
      category: category,
      createdAt: DateTime.now(),
      isAvailable: true,
      reference: link,
      description: description,
      price: itemPrice.toInt(),
      photos: state.item?.photos,
      userId: _authRepository.currentUser?.id,
    );
    emit(state.copyWith(item: model));
  }

  Future<void> createMarketplace() async {
    if (state.submitState.isLoading) return;
    emit(state.copyWith(submitState: state.submitState.loading()));
    try {
      if (state.placeId != null) {
        final locationResult =
            await _googlePlaces.fetchPlaceDetails(state.placeId!);
        emit(state.copyWith(
          item: state.item?.copyWith(
            location: Location.fromCoords(
              lat: locationResult.latLng?.lat ?? 0.0,
              long: locationResult.latLng?.lng ?? 0.0,
            ),
            address: locationResult.address,
          ),
        ));
      }
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(
            submitState: state.submitState.failure(UserNotAuthError())));
        return;
      }
      Stream<MarketplaceImageUploadTask> uploadImageStream =
          _marketplaceRepository.uploadImages(
        userId: userId,
        itemId: (state.item?.id ?? itemId).toString(),
        imagePaths: state.selectedImages.map((e) => e.path).toList(),
      );
      List<String> uploadedImagesUrl = [];
      await for (MarketplaceImageUploadTask value in uploadImageStream) {
        emit(state.copyWith(imageUploadTask: value));
        uploadedImagesUrl
          ..clear()
          ..addAll(value.urls?.toList() ?? []);
        _logger.info('Uploading: ${value.progress}');
      }
      MarketplaceModel? model = state.item?.copyWith(photos: uploadedImagesUrl);
      await _marketplaceRepository.createMarketplace(
        userId: userId,
        item: model!,
      );
      emit(state.copyWith(
        imageUploadTask: null,
        submitState: state.submitState.success(),
      ));
    } on AppException catch (e) {
      _logger.log('Error creating marketplace: $e');
      emit(state.copyWith(
        submitState: state.submitState.failure(e),
        imageUploadTask: null,
      ));
    } catch (e) {
      _logger.log('Error creating marketplace: $e');
      emit(state.copyWith(
        submitState: state.submitState
            .failure(UnknownMarketplaceError(hint: e.toString())),
        imageUploadTask: null,
      ));
    }
  }

  Future<void> updateMarketplace() async {
    if (state.submitState.isLoading) return;
    try {
      emit(state.copyWith(submitState: state.submitState.loading()));
      if (state.placeId != null) {
        final locationResult =
            await _googlePlaces.fetchPlaceDetails(state.placeId!);
        emit(state.copyWith(
          item: state.item?.copyWith(
            location: Location.fromCoords(
              lat: locationResult.latLng?.lat ?? 0.0,
              long: locationResult.latLng?.lng ?? 0.0,
            ),
            address: locationResult.address,
          ),
        ));
      }
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(
            submitState: state.submitState.failure(UserNotAuthError())));
        return;
      }
      List<String> uploadedImagesUrl = [];
      if (state.selectedImages.isNotEmpty) {
        Stream<MarketplaceImageUploadTask> uploadImageStream =
            _marketplaceRepository.uploadImages(
          userId: userId,
          itemId: (state.item?.id ?? itemId).toString(),
          imagePaths: state.selectedImages.map((e) => e.path).toList(),
        );
        await for (MarketplaceImageUploadTask value in uploadImageStream) {
          emit(state.copyWith(imageUploadTask: value));
          uploadedImagesUrl
            ..clear()
            ..addAll(value.urls?.toList() ?? []);
          _logger.info('Uploading: ${value.progress}');
        }
      }
      final List<String> finalImages;
      if (state.item?.photos != null) {
        finalImages = [...state.item!.photos!, ...uploadedImagesUrl];
      } else {
        finalImages = uploadedImagesUrl;
      }
      MarketplaceModel? model = state.item?.copyWith(photos: finalImages);
      await _marketplaceRepository.updateMarketplace(
        userId: userId,
        item: model!,
      );
      emit(state.copyWith(
        imageUploadTask: null,
        submitState: state.submitState.success(),
      ));
    } on AppException catch (e) {
      _logger.log('Error creating marketplace: $e');
      emit(state.copyWith(
        submitState: state.submitState.failure(e),
        imageUploadTask: null,
      ));
    } catch (e) {
      _logger.log('Error creating marketplace: $e');
      emit(state.copyWith(
        submitState: state.submitState
            .failure(UnknownMarketplaceError(hint: e.toString())),
        imageUploadTask: null,
      ));
    }
  }

  Future<List<MarketplaceCategoryModel>> getCategories() {
    return _marketplaceRepository.getMarketplaceCategories();
  }

  void loadMarketplaceCategories() {
    getCategories()
        .then((value) => emit(state.copyWith(marketplaceCategories: value)));
  }

  void addPickedImages(List<File> pickedImages) {
    List<File> images = [...state.selectedImages, ...pickedImages];
    emit(state.copyWith(selectedImages: images));
  }

  void removePickedImage(File image) {
    List<File> images = state.selectedImages;
    images.remove(image);
    emit(state.copyWith(selectedImages: images));
  }
}
