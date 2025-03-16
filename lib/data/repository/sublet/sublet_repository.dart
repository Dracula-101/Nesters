import 'package:nesters/domain/models/sublet/nearby_sublet_model.dart';
import 'package:nesters/domain/models/sublet/sublet_filter.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';

abstract class SubletRepository {
  Future<String> createSublet({
    required String userId,
    required SubletModel sublet,
  });

  Future<void> updateSublet({
    required String userId,
    required int subletId,
    required SubletModel sublet,
  });

  Stream<SubletImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String subletId,
  });

  Future<List<SubletModel>> getSublets({
    required String userId,
    int range,
    int paginationKey,
  });

  Future<List<NearbySubletModel>> getNearbySublets({
    required String userId,
    double rangeKm,
    int range,
    int paginationKey,
  });

  Future<List<SubletModel>> singleFilterSublet({
    required SingleSubletFilter filter,
    required String userId,
  });

  Future<List<SubletModel>> multiFilterSublet({
    required SubletFilter filter,
    required String userId,
  });

  Future<List<SubletModel>> getUserSublets({required String userId});

  Future<void> updateLikeStatus({
    required String userId,
    required int subletId,
    required bool isLiked,
  });

  Future<List<SubletModel>> getUserLikedSublets({required String userId});

  Future<void> changeSubletAvailabilityStatus({
    required String userId,
    required String subletId,
    required bool isAvailable,
  });

  Future<void> deleteUserSublet({
    required String userId,
    required String subletId,
  });
}

class SubletImageUploadTask {
  final List<String>? urls;
  final double progress;
  final Exception? error;

  SubletImageUploadTask({
    this.urls,
    this.progress = 0,
    this.error,
  });
}
