import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/amenities.dart';
import 'package:nesters/domain/models/sublet/apartment_size.dart';
import 'package:nesters/domain/models/sublet/lease_period.dart';
import 'package:nesters/domain/models/sublet/sublet_location.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'sublet_form_state.dart';
part 'sublet_form_cubit.freezed.dart';

class SubletFormCubit extends Cubit<SubletFormState> {
  SubletFormCubit() : super(SubletFormState.initial());

  final SubletRepository _subletRepository = GetIt.I<SubletRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();
  int subletId = DateTime.now().millisecondsSinceEpoch;

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
    required DateTime startDate,
    required DateTime endDate,
    required double rentPrice,
    required roomType,
    required String roomateGender,
    required int beds,
    required int baths,
  }) {
    SubletModel? model = SubletModel(
      id: subletId,
      location: Location(address: address),
      leasePeriod: LeasePeriod(startDate: startDate, endDate: endDate),
      rent: rentPrice,
      roomType: roomType,
      roommateGenderPref: roomateGender,
      apartmentSize: ApartmentSize(beds: beds, baths: baths),
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

  Future<void> createSublet(
    List<String> imagesPath,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? userId = _authRepository.currentUser?.id;
      if (userId == null) {
        emit(state.copyWith(submitError: Exception('User ID is null')));
        return;
      }
      Stream<SubletImageUploadTask> uploadImageStream =
          _subletRepository.uploadImages(
        userId: userId,
        subletId: subletId.toString(),
        imagePaths: imagesPath,
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
      _logger.log('Error creating sublet: $e');
      emit(state.copyWith(submitError: e));
    }
  }
}
