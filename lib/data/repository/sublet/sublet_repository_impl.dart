import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/sublet/error/sublet_error.dart';
import 'package:nesters/data/repository/sublet/sublet_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_filter.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/bloc/sublet_bloc.dart';
import 'package:nesters/utils/extensions/exception.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

class SubletRepositoryImpl implements SubletRepository {
  SubletRepositoryImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  final AppLogger _logger;

  @override
  Future<String> createSublet({
    required String userId,
    required SubletModel sublet,
  }) async {
    try {
      await _supabaseClient
          .from('sublets')
          .upsert(sublet.copyWith(userId: userId).toMap());
      _logger.info('Sublet created successfully with id: ${sublet.id}');
      return sublet.id.toString();
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.CREATE_SUBLET_ERROR,
        e.toString(),
      );
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
        final date = DateTime.now().toString();
        String supabasePath =
            '$basePathName/image_$date.${fileName.split('.').last}';
        await _supabaseClient.storage
            .from('sublets')
            .upload(supabasePath, file);
        String url =
            _supabaseClient.storage.from('sublets').getPublicUrl(supabasePath);
        urls.add(url);
        yield SubletImageUploadTask(
          urls: urls,
          progress: (index++ / imagePaths.length).clamp(0.1, 1.0),
        );
      }
    } on supabase.StorageException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.message.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.UPLOAD_IMAGES_ERROR,
        e.getException,
      );
    }
  }

  @override
  Future<List<SubletModel>> getSublets({
    required String userId,
    int range = 10,
    int paginationKey = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('sublets')
          .select("* sublet_likes!sublet_likes_sublet_id_fkey!left(*)")
          .neq("user_id", userId)
          .eq("is_available", true)
          .range(paginationKey, paginationKey + range)
          .order("id", ascending: false);
      return response.map((e) => SubletModel.fromMap(e)).toList();
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.GET_SUBLETS_ERROR,
        e.getException,
      );
    }
  }

  @override
  Future<List<SubletModel>> singleFilterSublet({
    required SingleSubletFilter filter,
    required String userId,
  }) {
    // singlesublet filter
    // - GenderPreferenceFilter, RentFilter, ApartmentTypeFilter, ApartmentSizeFilter
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("sublets").select();
      queryBuilder = queryBuilder.eq("is_available", true);
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
      queryBuilder = queryBuilder.neq("user_id", userId);
      PostgrestTransformBuilder<List<Map<String, dynamic>>> response =
          queryBuilder;
      if (filter is ApartmentSizeFilter) {
        response = response
            .order("beds", ascending: true)
            .order("baths", ascending: true);
      }
      return response
          .order("id", ascending: false)
          .select()
          .then((value) => value.map((e) => SubletModel.fromMap(e)).toList());
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.FILTER_SUBLET_ERROR,
        e.getException,
      );
    }
  }

  @override
  Future<List<SubletModel>> multiFilterSublet({
    required SubletFilter filter,
    required String userId,
  }) {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("sublets").select();
      queryBuilder = queryBuilder.eq("is_available", true);
      if (filter.amenitiesAvailable != null &&
          filter.amenitiesAvailable!.hasAmenities()) {
        if (filter.amenitiesAvailable!.hasAC != null &&
            filter.amenitiesAvailable!.hasAC == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_AC",
              filter.amenitiesAvailable!.hasAC ?? false);
        }
        if (filter.amenitiesAvailable!.hasGym != null &&
            filter.amenitiesAvailable!.hasGym == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_gym",
              filter.amenitiesAvailable!.hasGym ?? false);
        }
        if (filter.amenitiesAvailable!.hasPool != null &&
            filter.amenitiesAvailable!.hasPool == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_pool",
              filter.amenitiesAvailable!.hasPool ?? false);
        }
        if (filter.amenitiesAvailable!.hasDryer != null &&
            filter.amenitiesAvailable!.hasDryer == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_dryer",
              filter.amenitiesAvailable!.hasDryer ?? false);
        }
        if (filter.amenitiesAvailable!.hasPatio != null &&
            filter.amenitiesAvailable!.hasPatio == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_patio",
              filter.amenitiesAvailable!.hasPatio ?? false);
        }
        if (filter.amenitiesAvailable!.hasHeater != null &&
            filter.amenitiesAvailable!.hasHeater == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_heater",
              filter.amenitiesAvailable!.hasHeater ?? false);
        }
        if (filter.amenitiesAvailable!.hasBalcony != null &&
            filter.amenitiesAvailable!.hasBalcony == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_balcony",
              filter.amenitiesAvailable!.hasBalcony ?? false);
        }
        if (filter.amenitiesAvailable!.hasParking != null &&
            filter.amenitiesAvailable!.hasParking == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_parking",
              filter.amenitiesAvailable!.hasParking ?? false);
        }
        if (filter.amenitiesAvailable!.hasFurnished != null &&
            filter.amenitiesAvailable!.hasFurnished == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_furnished",
              filter.amenitiesAvailable!.hasFurnished ?? false);
        }
        if (filter.amenitiesAvailable!.hasDishwasher != null &&
            filter.amenitiesAvailable!.hasDishwasher == true) {
          queryBuilder = queryBuilder.eq("amenities_available->>has_dishwasher",
              filter.amenitiesAvailable!.hasDishwasher ?? false);
        }
        if (filter.amenitiesAvailable!.hasWashingMachine != null &&
            filter.amenitiesAvailable!.hasWashingMachine == true) {
          queryBuilder = queryBuilder.eq(
              "amenities_available->>has_washing_machine",
              filter.amenitiesAvailable!.hasWashingMachine ?? false);
        }
      }
      if (filter.apartmentSize != null && filter.apartmentSize?.beds != 0) {
        queryBuilder = queryBuilder.gte(
          "beds",
          filter.apartmentSize!.beds ?? 0,
        );
      }
      if (filter.apartmentSize != null && filter.apartmentSize?.baths != 0) {
        queryBuilder = queryBuilder.gte(
          "baths",
          filter.apartmentSize!.baths ?? 0,
        );
      }

      if (filter.startRent != null && filter.startRent != 0) {
        queryBuilder = queryBuilder.gte("rent", filter.startRent!.toInt());
      }
      if (filter.endRent != null && filter.endRent != 0) {
        queryBuilder = queryBuilder.lte("rent", filter.endRent!.toInt());
      }

      if (filter.roommateGenderPref != null &&
          filter.roommateGenderPref != "") {
        queryBuilder =
            queryBuilder.eq("roommate_gender_pref", filter.roommateGenderPref!);
      }
      if (filter.roomType != null) {
        queryBuilder = queryBuilder.eq(
          "room_type",
          filter.roomType.toString(),
        );
      }
      if (filter.leasePeriod != null && filter.leasePeriod?.startDate != null) {
        queryBuilder = queryBuilder.gte("start_date",
            filter.leasePeriod!.startDate!.millisecondsSinceEpoch);
      }
      queryBuilder = queryBuilder.neq("user_id", userId);
      return queryBuilder
          .order("id")
          .then((value) => value.map((e) => SubletModel.fromMap(e)).toList());
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.FILTER_SUBLET_ERROR,
        e.getException,
      );
    }
  }

  @override
  Future<List<SubletModel>> getUserSublets({required String userId}) async {
    try {
      final sublets = await _supabaseClient
          .from('sublets')
          .select()
          .eq('user_id', userId)
          .then((value) => value.map((e) => SubletModel.fromMap(e)).toList());
      return sublets;
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.GET_SUBLETS_ERROR,
        e.getException,
      );
    }
  }

  @override
  Future<void> updateSublet(
      {required String userId,
      required int subletId,
      required SubletModel sublet}) async {
    try {
      final sublets = await _supabaseClient
          .from('sublets')
          .update({...sublet.toMap(), 'user_id': userId})
          .eq('id', subletId)
          .eq('user_id', userId);
      _logger.info('Sublet updated successfully with id: $subletId');
      return sublets;
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.CREATE_SUBLET_ERROR,
        e.toString(),
      );
    }
  }

  @override
  Future<void> updateLikeStatus({
    required String userId,
    required int subletId,
    required bool isLiked,
  }) async {
    try {
      await _supabaseClient.from('sublet_likes').upsert({
        'user_id': userId,
        'sublet_id': subletId,
        'is_liked': isLiked,
      }, onConflict: 'sublet_id');
      _logger.info(
          'Like status updated successfully for sublet: $subletId -> ${isLiked ? '❤️' : '💔'}');
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.UPDATE_LIKE_STATUS_ERROR,
        e.toString(),
      );
    }
  }

  @override
  Future<List<SubletModel>> getUserLikedSublets(
      {required String userId}) async {
    try {
      final likedSublets = await _supabaseClient
          .from('sublets')
          .select('*, sublet_likes!sublet_likes_sublet_id_fkey!inner(*)')
          .eq('sublet_likes.user_id', userId)
          .eq('sublet_likes.is_liked', true)
          .then((value) => value.map((e) => SubletModel.fromMap(e)).toList());
      return likedSublets;
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.GET_SUBLETS_ERROR,
        e.getException,
      );
    }
  }

  @override
  Future<void> changeSubletAvailabilityStatus({
    required String userId,
    required String subletId,
    required bool isAvailable,
  }) async {
    try {
      await _supabaseClient
          .from('sublets')
          .update({
            'is_available': isAvailable,
          })
          .eq('id', subletId)
          .eq('user_id', userId);
      _logger.info(
          'Sublet ${isAvailable ? 'Shown' : 'Hidden'} successfully with id: $subletId');
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.CHANGE_SUBLET_AVAILABILITY_STATUS_ERROR,
        e.toString(),
      );
    }
  }

  @override
  Future<void> deleteUserSublet({
    required String userId,
    required String subletId,
  }) async {
    try {
      await _supabaseClient
          .from('sublets')
          .delete()
          .eq('id', subletId)
          .eq('user_id', userId);
      _logger.info('Sublet deleted successfully with id: $subletId');
    } on supabase.PostgrestException catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DB_ERROR,
        e.details.toString(),
      );
    } on Exception catch (e) {
      throw SubletErrorFactory.createSubletError(
        SubletErrorCode.DELETE_SUBLET_ERROR,
        e.toString(),
      );
    }
  }
}
