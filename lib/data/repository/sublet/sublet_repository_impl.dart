import 'dart:io';

import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

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
}
