import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';

abstract class MarketplaceRepository {
  Future<String> createMarketplace({
    required String userId,
    required MarketplaceModel item,
  });

  Stream<MarketplaceImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String itemId,
  });

  Future<List<MarketplaceModel>> getMarketplaces(
      {int range = 10, int paginationKey = 0});

  Future<List<MarketplaceCategoryModel>> getMarketplaceCategories();
}

class MarketplaceImageUploadTask {
  final List<String>? urls;
  final double progress;
  final Exception? error;

  MarketplaceImageUploadTask({
    this.urls,
    this.progress = 0,
    this.error,
  });
}
