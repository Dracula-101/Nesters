import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

class SubletRepositoryImpl implements SubletRepository {
  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  @override
  Future<String> createSublet({
    required String userId,
    required SubletModel sublet,
  }) async {
    try {
      await _supabaseClient
          .from('sublets')
          .upsert(sublet.copyWith(userId: userId).toMap());
      return sublet.id.toString();
    } catch (e) {
      throw Exception('Failed to create sublet: $e');
    }
  }

  @override
  Stream<SubletImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String subletId,
  }) async* {
    try {
      String basePathName = '$userId/$subletId';
      int noOfFiles = (await _supabaseClient.storage
              .from('sublets')
              .list(path: basePathName))
          .length;
      yield SubletImageUploadTask(urls: [], progress: 0.025);
      if (noOfFiles == imagePaths.length) {
        await _supabaseClient.storage.from('sublets').remove([basePathName]);
        yield SubletImageUploadTask(urls: [], progress: 0.05);
      }
      List<String> urls = [];
      int index = 0;
      for (final imagePath in imagePaths) {
        final file = File(imagePath);
        final fileName = file.path.split('/').last;
        String supabasePath =
            '$basePathName/image_$index.${fileName.split('.').last}';
        await _supabaseClient.storage
            .from('sublets')
            .upload(supabasePath, file);
        String url =
            _supabaseClient.storage.from('sublets').getPublicUrl(supabasePath);
        urls.add(url);
        yield SubletImageUploadTask(
          urls: urls,
          progress: index++ / imagePaths.length,
        );
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  @override
  Future<List<SubletModel>> getSublets(
      {int range = 10, int paginationKey = 0}) async {
    try {
      final response = await _supabaseClient
          .from('sublets')
          .select()
          .range(paginationKey, paginationKey + range);
      return response.map((e) => SubletModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to get sublets: $e');
    }
  }

  @override
  Future<List<SubletModel>> singleFilterSublet(
      {required SingleSubletFilter filter}) {
    // singlesublet filter
    // - GenderPreferenceFilter, RentFilter, ApartmentTypeFilter, ApartmentSizeFilter
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("sublets").select();
      if (filter is GenderPreferenceFilter) {
        queryBuilder = queryBuilder.eq(
            "roommate_gender_pref", filter.preferredGender.toString());
      } else if (filter is RentFilter) {
        queryBuilder = queryBuilder
            .gte("rent", filter.startRent)
            .lte("rent", filter.endRent);
      } else if (filter is ApartmentTypeFilter) {
        queryBuilder =
            queryBuilder.eq("room_type", filter.apartmentType.toString());
      } else if (filter is ApartmentSizeFilter) {
        log("Filter Apartment Size: ${filter.apartmentSize.beds} Beds, ${filter.apartmentSize.baths} Baths");
        queryBuilder = queryBuilder
            .gte("beds", filter.apartmentSize.beds ?? 0)
            .gte("baths", filter.apartmentSize.baths ?? 0);
      }
      PostgrestTransformBuilder<List<Map<String, dynamic>>> response =
          queryBuilder;
      if (filter is ApartmentSizeFilter) {
        response = response
            .order("beds", ascending: true)
            .order("baths", ascending: true);
      }
      return response
          .order("created_at", ascending: false)
          .select()
          .then((value) => value.map((e) => SubletModel.fromMap(e)).toList());
    } catch (e) {
      throw Exception('Failed to get sublets: $e');
    }
  }
}
