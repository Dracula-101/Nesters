import 'package:nesters/domain/models/apartment/apartment_filter.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/list/bloc/apartment_bloc.dart';

abstract class ApartmentRepository {
  Future<String> createApartment({
    required String userId,
    required ApartmentModel apartment,
  });

  Future<void> updateApartment({
    required String userId,
    required int apartmentId,
    required ApartmentModel apartment,
  });

  Stream<ApartmentImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String apartmentId,
  });

  Future<List<ApartmentModel>> getApartments({
    required String userId,
    int range = 10,
    int paginationKey = 0,
  });

  Future<List<ApartmentModel>> singleFilterApartment({
    required SingleApartmentFilter filter,
    required String userId,
  });

  Future<List<ApartmentModel>> multiFilterApartment({
    required ApartmentFilter filter,
    required String userId,
  });

  Future<List<ApartmentModel>> getUserApartments({required String userId});

  Future<void> updateLikeStatus({
    required String userId,
    required int apartmentId,
    required bool isLiked,
  });

  Future<List<ApartmentModel>> getUserLikedApartments({required String userId});

  Future<void> changeApartmentAvailabilityStatus({
    required String userId,
    required String apartmentId,
    required bool isAvailable,
  });

  Future<void> deleteUserApartment({
    required String userId,
    required String apartmentId,
  });
}

class ApartmentImageUploadTask {
  final List<String>? urls;
  final double progress;
  final Exception? error;

  ApartmentImageUploadTask({
    this.urls,
    this.progress = 0,
    this.error,
  });
}
