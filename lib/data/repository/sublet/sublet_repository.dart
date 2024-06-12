import 'package:nesters/domain/models/sublet/sublet_model.dart';

abstract class SubletRepository {
  Future<String> createSublet({
    required String userId,
    required SubletModel sublet,
  });

  Stream<SubletImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String subletId,
  });

  Future<List<SubletModel>> getSublets({int maxResults = 10});
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
