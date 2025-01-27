import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';

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

  Future<bool> updateMarketplace({
    required String userId,
    required MarketplaceModel item,
  });

  Future<List<MarketplaceModel>> getMarketplaces({
    required String userId,
    int range = 10,
    int paginationKey = 0,
  });

  Future<List<MarketplaceCategoryModel>> getMarketplaceCategories();

  Future<List<MarketplaceModel>> getSingleFilteredMarketplaces(
      MarketplaceSingleFilter filter);

  Future<List<MarketplaceModel>> getUserMarketplaces({required String userId});

  Future<void> updateLikeStatus({
    required String userId,
    required int itemId,
    required bool isLiked,
  });

  Future<List<MarketplaceModel>> getUserLikedMarketplaces({
    required String userId,
  });

  Future<void> changeAvailabilityStatus({
    required String userId,
    required int itemId,
    required bool isAvailable,
  });

  Future<void> deleteUserMarketplace({
    required String userId,
    required int itemId,
  });
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
