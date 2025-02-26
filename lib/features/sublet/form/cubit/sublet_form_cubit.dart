import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/features/sublet/form/cubit/sublet_form_error.dart';
import 'package:nesters/utils/bloc_state.dart';
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
      address: address,
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
    required Amenities amenities,
  }) {
    SubletModel? model = state.sublet?.copyWith(
      roomDescription: roomDescription,
      roommateDescription: roommateDescription,
      amenitiesAvailable: amenities,
    );
    emit(state.copyWith(sublet: model));
  }

  Future<void> createSublet() async {
    if (state.submitState?.isLoading ?? false) return;
    try {
      emit(state.copyWith(submitState: state.submitState?.loading()));
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(
            submitState: state.submitState?.failure(UserNotAuthError())));
        return;
      }
      if (state.pickedImages.isEmpty) {
        emit(state.copyWith(
            submitState: state.submitState?.failure(SelectOneImageError())));
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
        emit(state.copyWith(
            submitState:
                state.submitState?.failure(NoUploadImagePresentError())));
        return;
      }
      SubletModel? model = state.sublet?.copyWith(photos: uploadedImagesUrl);
      await _subletRepository.createSublet(
        userId: userId,
        sublet: model!,
      );
      emit(state.copyWith(
        imageUploadTask: null,
        submitState: state.submitState?.success(),
      ));
    } on AppException catch (e) {
      _logger.error('Error creating sublet: $e');
      emit(
        state.copyWith(
            submitState: state.submitState?.failure(e), imageUploadTask: null),
      );
    }
  }

  Future<void> updateSublet() async {
    if (state.submitState?.isLoading ?? false) return;
    try {
      emit(state.copyWith(submitState: state.submitState?.loading()));
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(
            submitState: state.submitState?.failure(UserNotAuthError())));
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
        imageUploadTask: null,
        submitState: state.submitState?.success(),
      ));
    } on AppException catch (e) {
      _logger.error('Error updating sublet: $e');
      emit(state.copyWith(
          submitState: state.submitState?.failure(e), imageUploadTask: null));
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
