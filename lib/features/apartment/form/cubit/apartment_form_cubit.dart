import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/domain/models/apartment/apartment_size.dart';
import 'package:nesters/domain/models/apartment/lease_period.dart';
import 'package:nesters/domain/models/user/location.dart';
import 'package:nesters/features/apartment/form/cubit/apartment_error.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'apartment_form_state.dart';

class ApartmentFormCubit extends Cubit<ApartmentFormState> {
  ApartmentFormCubit({
    ApartmentModel? apartment,
  }) : super(const ApartmentFormState(
          hasSecondPageAccess: kDebugMode,
        )) {
    if (apartment != null) {
      preFillApartment(apartment);
    }
  }

  final ApartmentRepository _apartmentRepository =
      GetIt.I<ApartmentRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  int apartmentId = DateTime.now().millisecondsSinceEpoch;

  void preFillApartment(ApartmentModel apartment) {
    emit(state.copyWith(
      apartment: apartment,
      isPreFilled: true,
      hasSecondPageAccess: true,
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
    }
  }

  void addFirstPageData({
    required String address,
    required DateTime? startDate,
    required double rentPrice,
    required int beds,
    required int baths,
    required String apartmentDescription,
    required Amenities amenitiesAvailable,
  }) {
    final userId = _authRepository.currentUser?.id;
    ApartmentModel model = ApartmentModel(
      id: state.apartment?.id ?? apartmentId,
      address: address,
      leasePeriod: LeasePeriod(
        startDate: startDate,
      ),
      rent: rentPrice,
      apartmentSize: ApartmentSize(
        beds: beds,
        baths: baths,
      ),
      photos: state.apartment?.photos,
      amenitiesAvailable: amenitiesAvailable,
      apartmentDescription: apartmentDescription,
      isAvailable: state.apartment?.isAvailable,
      userId: state.apartment?.userId ?? userId,
    );
    emit(
      state.copyWith(
        apartment: model,
      ),
    );
  }

  Future<void> createApartment() async {
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
            submitState:
                state.submitState?.failure(UserNoPhotosUploadError())));
        return;
      }
      Stream<ApartmentImageUploadTask> uploadImageStream =
          _apartmentRepository.uploadImages(
        userId: userId,
        apartmentId: apartmentId.toString(),
        imagePaths: state.pickedImages.map((e) => e.path).toList(),
      );
      List<String> uploadedImagesUrl = [];
      await for (ApartmentImageUploadTask value in uploadImageStream) {
        emit(state.copyWith(imageUploadTask: value));
        uploadedImagesUrl
          ..clear()
          ..addAll(value.urls?.toList() ?? []);
        _logger.info('Uploading: ${value.progress}');
      }
      if (uploadedImagesUrl.isEmpty) {
        emit(state.copyWith(
            submitState:
                state.submitState?.failure(UserNoPhotosUploadError())));
        return;
      }
      ApartmentModel? model =
          state.apartment?.copyWith(photos: uploadedImagesUrl);
      await _apartmentRepository.createApartment(
        userId: userId,
        apartment: model!,
      );
      emit(state.copyWith(
        imageUploadTask: null,
        submitState: state.submitState?.success(),
      ));
    } on AppException catch (e) {
      _logger.error('Error creating apartment: $e');
      emit(state.copyWith(
        submitState: state.submitState?.failure(e),
        imageUploadTask: null,
      ));
    }
  }

  Future<void> updateApartment() async {
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
        Stream<ApartmentImageUploadTask> uploadImageStream =
            _apartmentRepository.uploadImages(
          userId: userId,
          apartmentId: state.apartment?.id.toString() ?? '',
          imagePaths: state.pickedImages.map((e) => e.path).toList(),
        );
        await for (ApartmentImageUploadTask value in uploadImageStream) {
          emit(state.copyWith(imageUploadTask: value));
          uploadedImagesUrl
            ..clear()
            ..addAll(value.urls?.toList() ?? []);
          _logger.info('Uploading: ${value.progress}');
        }
      }
      final List<String> finalImages;
      if (state.apartment?.photos != null) {
        finalImages = [...state.apartment!.photos!, ...uploadedImagesUrl];
      } else {
        finalImages = uploadedImagesUrl;
      }
      ApartmentModel? model = state.apartment?.copyWith(photos: finalImages);
      await _apartmentRepository.updateApartment(
        userId: userId,
        apartmentId: state.apartment?.id ?? 0,
        apartment: model!,
      );
      emit(
        state.copyWith(
          imageUploadTask: null,
          submitState: state.submitState?.success(),
        ),
      );
    } on AppException catch (e) {
      _logger.error('Error updating apartment: $e');
      emit(
        state.copyWith(
          submitState: state.submitState?.failure(e),
          imageUploadTask: null,
        ),
      );
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
