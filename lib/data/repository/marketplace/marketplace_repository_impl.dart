import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/marketplace/marketplace_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_category_model.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/bloc/marketplace_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  @override
  Future<String> createMarketplace(
      {required String userId, required MarketplaceModel item}) async {
    try {
      await _supabaseClient
          .from('marketplaces')
          .upsert(item.copyWith(userId: userId).toJson());
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
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<MarketplaceModel>> getMarketplaces(
      {int range = 10, int paginationKey = 0}) async {
    try {
      final response = await _supabaseClient
          .from('marketplaces')
          .select()
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
      MarketplaceSingleFilter filter) {
    try {
      supabase.PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("marketplaces").select();
      if (filter is MarketplaceCategoryFilter) {
        queryBuilder =
            queryBuilder.eq('category->>id', filter.category.id ?? 0);
      }
      return queryBuilder.order("created_at", ascending: false).select().then(
          (response) =>
              response.map((e) => MarketplaceModel.fromJson(e)).toList());
    } catch (e) {
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
}
