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

  Future<List<SubletModel>> getSublets({int range = 10, int paginationKey = 0});

  Future<List<SubletModel>> singleFilterSublet({
    required SingleSubletFilter filter,
  });

  Future<List<SubletModel>> multiFilterSublet({
    required SubletFilter filter,
  });

  Future<List<SubletModel>> getSubletsByUserId({required String userId});
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
