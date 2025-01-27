import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/amenities.dart';
import 'package:nesters/domain/models/sublet/apartment_size.dart';
import 'package:nesters/domain/models/sublet/lease_period.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'sublet_form_state.dart';

class SubletFormCubit extends Cubit<SubletFormState> {
  SubletFormCubit({
    SubletModel? sublet,
  }) : super(const SubletFormState(
          hasSecondPageAccess: kDebugMode,
          hasThirdPageAccess: kDebugMode,
        )) {
    if (sublet != null) {
      preFillSublet(sublet);
    }
  }

  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  int subletId = DateTime.now().millisecondsSinceEpoch;

  void preFillSublet(SubletModel sublet) {
    emit(state.copyWith(
      sublet: sublet,
      isPreFilled: true,
      hasSecondPageAccess: true,
      hasThirdPageAccess: true,
    ));
  }

  void validatePage() {
    emit(state.copyWith(isValidating: false));
    emit(state.copyWith(isValidating: true));
  }

  void onPageChange(int pageNumber) {
    emit(state.copyWith(pageNumber: pageNumber, isValidating: false));
  }

  void showPageValid(int page) {
    if (page == 1) {
      emit(state.copyWith(hasSecondPageAccess: true));
    } else if (page == 2) {
      emit(state.copyWith(hasThirdPageAccess: true));
    }
  }

  void addFirstPageData({
    required String address,
    required DateTime? startDate,
    required DateTime? endDate,
    required double rentPrice,
    required roomType,
    required String roomateGender,
    required int beds,
    required int baths,
  }) {
    SubletModel model = SubletModel(
      id: state.sublet?.id ?? subletId,
      location: Location(address: address),
      leasePeriod: LeasePeriod(startDate: startDate, endDate: endDate),
      rent: rentPrice,
      roomType: roomType,
      roommateGenderPref: roomateGender,
      apartmentSize: ApartmentSize(beds: beds, baths: baths),
      photos: state.sublet?.photos,
      amenitiesAvailable: state.sublet?.amenitiesAvailable,
      roomDescription: state.sublet?.roomDescription,
      roommateDescription: state.sublet?.roommateDescription,
      isAvailable: state.sublet?.isAvailable,
      userId: state.sublet?.userId,
    );
    emit(state.copyWith(sublet: model));
  }

  void addSecondPageData({
    required String roomDescription,
    required String roommateDescription,
    required bool hasAC,
    required bool hasBalcony,
    required bool hasDishwasher,
    required bool hasDryer,
    required bool hasFurnished,
    required bool hasGym,
    required bool hasHeater,
    required bool hasParking,
    required bool hasPatio,
    required bool hasPool,
    required bool hasWashingMachine,
  }) {
    SubletModel? model = state.sublet?.copyWith(
      roomDescription: roomDescription,
      roommateDescription: roommateDescription,
      amenitiesAvailable: Amenities(
        hasAC: hasAC,
        hasBalcony: hasBalcony,
        hasDishwasher: hasDishwasher,
        hasDryer: hasDryer,
        hasFurnished: hasFurnished,
        hasGym: hasGym,
        hasHeater: hasHeater,
        hasParking: hasParking,
        hasPatio: hasPatio,
        hasPool: hasPool,
        hasWashingMachine: hasWashingMachine,
      ),
    );
    emit(state.copyWith(sublet: model));
  }

  Future<void> createSublet() async {
    if (state.isSubmitting ?? false) return;
    try {
      emit(state.copyWith(isSubmitting: true));
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(submitError: Exception('User ID is null')));
        return;
      }
      if (state.pickedImages.isEmpty) {
        emit(state.copyWith(submitError: Exception('No images selected')));
        return;
      }
      Stream<SubletImageUploadTask> uploadImageStream =
          _subletRepository.uploadImages(
        userId: userId,
        subletId: subletId.toString(),
        imagePaths: state.pickedImages.map((e) => e.path).toList(),
      );
      List<String> uploadedImagesUrl = [];
      await for (SubletImageUploadTask value in uploadImageStream) {
        emit(state.copyWith(imageUploadTask: value));
        uploadedImagesUrl
          ..clear()
          ..addAll(value.urls?.toList() ?? []);
        _logger.info('Uploading: ${value.progress}');
      }
      if (uploadedImagesUrl.isEmpty) {
        emit(state.copyWith(submitError: Exception('No images uploaded')));
        return;
      }
      SubletModel? model = state.sublet?.copyWith(photos: uploadedImagesUrl);
      await _subletRepository.createSublet(
        userId: userId,
        sublet: model!,
      );
      emit(state.copyWith(
        submitError: null,
        imageUploadTask: null,
        isSubmitting: false,
        isSubmitComplete: true,
      ));
    } on Exception catch (e) {
      _logger.error('Error creating sublet: $e');
      emit(state.copyWith(
          submitError: e,
          isSubmitting: false,
          isSubmitComplete: false,
          imageUploadTask: null));
    }
  }

  Future<void> updateSublet() async {
    if (state.isSubmitting ?? false) return;
    try {
      emit(state.copyWith(isSubmitting: true));
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(submitError: Exception('User ID is null')));
        return;
      }
      List<String> uploadedImagesUrl = [];
      if (state.pickedImages.isNotEmpty) {
        Stream<SubletImageUploadTask> uploadImageStream =
            _subletRepository.uploadImages(
          userId: userId,
          subletId: state.sublet?.id.toString() ?? '',
          imagePaths: state.pickedImages.map((e) => e.path).toList(),
        );
        await for (SubletImageUploadTask value in uploadImageStream) {
          emit(state.copyWith(imageUploadTask: value));
          uploadedImagesUrl
            ..clear()
            ..addAll(value.urls?.toList() ?? []);
          _logger.info('Uploading: ${value.progress}');
        }
      }
      final List<String> finalImages;
      if (state.sublet?.photos != null) {
        finalImages = [...state.sublet!.photos!, ...uploadedImagesUrl];
      } else {
        finalImages = uploadedImagesUrl;
      }
      SubletModel? model = state.sublet?.copyWith(photos: finalImages);
      await _subletRepository.updateSublet(
        userId: userId,
        subletId: state.sublet?.id ?? 0,
        sublet: model!,
      );
      emit(state.copyWith(
        submitError: null,
        imageUploadTask: null,
        isSubmitting: false,
        isSubmitComplete: true,
      ));
    } on Exception catch (e) {
      _logger.error('Error updating sublet: $e');
      emit(state.copyWith(
          submitError: e,
          isSubmitting: false,
          isSubmitComplete: false,
          imageUploadTask: null));
    }
  }

  void addImages(List<File> images) {
    List<File> pickedImages = [...state.pickedImages, ...images];
    emit(state.copyWith(pickedImages: pickedImages));
  }

  void removeImage(File image) {
    emit(state.copyWith(pickedImages: state.pickedImages..remove(image)));
  }
}
