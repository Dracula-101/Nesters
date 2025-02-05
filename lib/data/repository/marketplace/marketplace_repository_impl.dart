import 'dart:io';

import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;
  final AppLogger _logger;

  @override
  Future<String> createMarketplace(
      {required String userId, required MarketplaceModel item}) async {
    try {
      await _supabaseClient
          .from('marketplaces')
          .upsert(item.copyWith(userId: userId).toJson());
      _logger.info('Marketplace created successfully with id: ${item.id}');
      return item.id.toString();
    } catch (e) {
      throw Exception('Failed to create Marketplace: $e');
    }
  }

  @override
  Stream<MarketplaceImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String itemId,
  }) async* {
    try {
      String basePathName = '$userId/$itemId';
      int noOfFiles = (await _supabaseClient.storage
              .from('marketplaces')
              .list(path: basePathName))
          .length;
      yield MarketplaceImageUploadTask(urls: [], progress: 0.025);
      if (noOfFiles == imagePaths.length) {
        await _supabaseClient.storage
            .from('marketplaces')
            .remove([basePathName]);
        yield MarketplaceImageUploadTask(urls: [], progress: 0.05);
      }
      List<String> urls = [];
      int index = 0;
      for (final imagePath in imagePaths) {
        final file = File(imagePath);
        final fileName = file.path.split('/').last;
        final date = DateTime.now().toString();
        String supabasePath =
            '$basePathName/image_$date.${fileName.split('.').last}';
        await _supabaseClient.storage
            .from('marketplaces')
            .upload(supabasePath, file);
        String url = _supabaseClient.storage
            .from('marketplaces')
            .getPublicUrl(supabasePath);
        urls.add(url);
        yield MarketplaceImageUploadTask(
          urls: urls,
          progress: (index++ / imagePaths.length).clamp(0.1, 1.0),
        );
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  @override
  Future<bool> updateMarketplace({
    required String userId,
    required MarketplaceModel item,
  }) async {
    try {
      await _supabaseClient
          .from('marketplaces')
          .update({...item.toJson(), 'user_id': userId})
          .eq('id', item.id)
          .eq('user_id', userId);
      _logger.info('Marketplace updated successfully with id: ${item.id}');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<MarketplaceModel>> getMarketplaces({
    required String userId,
    int range = 10,
    int paginationKey = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('marketplaces')
          .select(
              "*, marketplaces_likes!marketplace_likes_marketplace_id_fkey!left(*)")
          .neq('user_id', userId)
          .order('created_at', ascending: false)
          .range(paginationKey, paginationKey + range);
      return response.map((e) => MarketplaceModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get Marketplaces: $e');
    }
  }

  @override
  Future<List<MarketplaceCategoryModel>> getMarketplaceCategories() async {
    try {
      final response =
          await _supabaseClient.from('marketplaces_categories').select();
      return response.map((e) => MarketplaceCategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get Marketplace Categories: $e');
    }
  }

  @override
  Future<List<MarketplaceModel>> getSingleFilteredMarketplaces(
    MarketplaceSingleFilter filter,
    String userId,
  ) {
    try {
      supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("marketplaces").select();
      if (filter is MarketplaceCategoryFilter) {
        queryBuilder =
            queryBuilder.eq('category->>id', filter.category.id ?? 0);
      }
      return queryBuilder
          .neq(
            "user_id",
            userId,
          )
          .order("created_at", ascending: false)
          .select()
          .then((response) =>
              response.map((e) => MarketplaceModel.fromJson(e)).toList());
    } catch (e) {
      throw Exception('Failed to get Marketplaces: $e');
    }
  }

  @override
  Future<List<MarketplaceModel>> getMultipleFilteredMarketplaces(
    MarketplaceAdvancedFilter filter,
    String userId,
  ) async {
    try {
      supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("marketplaces").select();
      if (filter.minPrice != null) {
        queryBuilder = queryBuilder.gte('price', filter.minPrice!.toInt());
      }
      if (filter.maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', filter.maxPrice!.toInt());
      }
      if (filter.category != null) {
        queryBuilder =
            queryBuilder.eq('category->>name', filter.category!.name ?? '');
      }
      if (filter.keyword != null) {
        queryBuilder = queryBuilder.contains('title', filter.keyword!);
      }
      return queryBuilder
          .neq("user_id", userId)
          .order(
            "created_at",
            ascending: false,
          )
          .select()
          .then(
            (response) =>
                response.map((e) => MarketplaceModel.fromJson(e)).toList(),
          );
    } on Exception catch (e) {
      throw Exception('Failed to get Marketplaces: $e');
    }
  }

  @override
  Future<List<MarketplaceModel>> getUserMarketplaces({required String userId}) {
    try {
      return _supabaseClient
          .from('marketplaces')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .then((response) =>
              response.map((e) => MarketplaceModel.fromJson(e)).toList());
    } catch (e) {
      throw Exception('Failed to get User Marketplaces: $e');
    }
  }

  @override
  Future<void> updateLikeStatus({
    required String userId,
    required int itemId,
    required bool isLiked,
  }) async {
    try {
      await _supabaseClient.from('marketplaces_likes').upsert(
          {'user_id': userId, 'marketplace_id': itemId, 'is_liked': isLiked},
          onConflict: 'marketplace_id');
      _logger.info(
          'Like status updated successfully for sublet: $itemId -> ${isLiked ? '❤️' : '💔'}');
    } catch (e) {
      throw Exception('Failed to update like status: $e');
    }
  }

  @override
  Future<List<MarketplaceModel>> getUserLikedMarketplaces({
    required String userId,
  }) {
    try {
      return _supabaseClient
          .from('marketplaces')
          .select(
              "*, marketplaces_likes!marketplace_likes_marketplace_id_fkey!inner(*)")
          .eq('marketplaces_likes.user_id', userId)
          .eq('marketplaces_likes.is_liked', true)
          .then((response) =>
              response.map((e) => MarketplaceModel.fromJson(e)).toList());
    } catch (e) {
      throw Exception('Failed to get Liked Marketplaces: $e');
    }
  }

  @override
  Future<void> changeAvailabilityStatus({
    required String userId,
    required int itemId,
    required bool isAvailable,
  }) async {
    try {
      await _supabaseClient
          .from('marketplaces')
          .update({'is_available': isAvailable})
          .eq('id', itemId)
          .eq('user_id', userId);
      _logger.info(
          'Availability status updated successfully for sublet: $itemId -> ${isAvailable ? 'Available' : 'Not Available'}');
    } catch (e) {
      throw Exception('Failed to update availability status: $e');
    }
  }

  @override
  Future<void> deleteUserMarketplace({
    required String userId,
    required int itemId,
  }) async {
    try {
      await _supabaseClient
          .from('marketplaces')
          .delete()
          .eq('id', itemId)
          .eq('user_id', userId);
      _logger.info('Marketplace deleted successfully with id: $itemId');
    } catch (e) {
      throw Exception('Failed to delete Marketplace: $e');
    }
  }
}
