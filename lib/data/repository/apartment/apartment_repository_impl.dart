import 'dart:developer';
import 'dart:io';
import 'package:nesters/data/repository/apartment/apartment_repository.dart';
import 'package:nesters/data/repository/apartment/error/apartment_error.dart';
import 'package:nesters/data/repository/network/network_error.dart';
import 'package:nesters/domain/models/apartment/apartment_filter.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/list/bloc/apartment_bloc.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApartmentRepositoryImpl implements ApartmentRepository {
  ApartmentRepositoryImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  final AppLogger _logger;

  @override
  Future<String> createApartment({
    required String userId,
    required ApartmentModel apartment,
  }) async {
    try {
      await _supabaseClient
          .from('apartments')
          .upsert(apartment.copyWith(userId: userId).toMap());
      _logger.info('Apartment created successfully with id: ${apartment.id}');
      return apartment.id.toString();
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.DB_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.CREATE_APARTMENT_ERR,
        e.toString(),
      );
    }
  }

  @override
  Stream<ApartmentImageUploadTask> uploadImages({
    required List<String> imagePaths,
    required String userId,
    required String apartmentId,
  }) async* {
    try {
      String basePathName = '$userId/$apartmentId';
      int noOfFiles = (await _supabaseClient.storage
              .from('apartments')
              .list(path: basePathName))
          .length;
      yield ApartmentImageUploadTask(urls: [], progress: 0.025);
      if (noOfFiles == imagePaths.length) {
        await _supabaseClient.storage.from('apartments').remove([basePathName]);
        yield ApartmentImageUploadTask(urls: [], progress: 0.05);
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
            .from('apartments')
            .upload(supabasePath, file);
        String url = _supabaseClient.storage
            .from('apartments')
            .getPublicUrl(supabasePath);
        urls.add(url);
        yield ApartmentImageUploadTask(
          urls: urls,
          progress: (index++ / imagePaths.length).clamp(0.1, 1.0),
        );
      }
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.UPLOAD_IMAGES_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.UPLOAD_IMAGES_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<List<ApartmentModel>> getApartments({
    required String userId,
    int range = 10,
    int paginationKey = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('apartments')
          .select(
              "*, apartment_likes!apartment_likes_apartment_id_fkey!left(*)")
          .neq("user_id", userId)
          .eq("is_available", true)
          .range(paginationKey, paginationKey + range)
          .order("id", ascending: false);
      return response.map((e) => ApartmentModel.fromMap(e)).toList();
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.GET_APARTMENTS_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.GET_APARTMENTS_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<List<ApartmentModel>> singleFilterApartment({
    required SingleApartmentFilter filter,
    required String userId,
  }) {
    // singleapartment filter
    // - GenderPreferenceFilter, RentFilter, ApartmentTypeFilter, ApartmentSizeFilter
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("apartments").select();
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
      return response.order("id", ascending: false).select().then(
          (value) => value.map((e) => ApartmentModel.fromMap(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.FILTER_APARTMENT_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.FILTER_APARTMENT_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<List<ApartmentModel>> multiFilterApartment({
    required ApartmentFilter filter,
    required String userId,
  }) {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from("apartments").select();
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

      if (filter.leasePeriod != null && filter.leasePeriod?.startDate != null) {
        queryBuilder = queryBuilder.gte("start_date",
            filter.leasePeriod!.startDate!.millisecondsSinceEpoch);
      }
      queryBuilder = queryBuilder.neq("user_id", userId);
      return queryBuilder.order("id").then(
          (value) => value.map((e) => ApartmentModel.fromMap(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.FILTER_APARTMENT_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.FILTER_APARTMENT_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<List<ApartmentModel>> getUserApartments(
      {required String userId}) async {
    try {
      final apartments = await _supabaseClient
          .from('apartments')
          .select()
          .eq('user_id', userId)
          .then(
              (value) => value.map((e) => ApartmentModel.fromMap(e)).toList());
      return apartments;
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.GET_APARTMENTS_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.GET_APARTMENTS_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<void> updateApartment(
      {required String userId,
      required int apartmentId,
      required ApartmentModel apartment}) async {
    try {
      log(apartment.toMap().toString());
      final apartments = await _supabaseClient
          .from('apartments')
          .update({...apartment.toMap(), 'user_id': userId})
          .eq('id', apartmentId)
          .eq('user_id', userId);
      _logger.info('Apartment updated successfully with id: $apartmentId');
      return apartments;
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.UPDATE_APARTMENT_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.UPDATE_APARTMENT_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<void> updateLikeStatus({
    required String userId,
    required int apartmentId,
    required bool isLiked,
  }) async {
    try {
      await _supabaseClient.from('apartment_likes').upsert({
        'user_id': userId,
        'apartment_id': apartmentId,
        'is_liked': isLiked,
      }, onConflict: 'apartment_id');
      _logger.info(
          'Like status updated successfully for apartment: $apartmentId -> ${isLiked ? '❤️' : '💔'}');
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.UPDATE_LIKE_STATUS_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.UPDATE_LIKE_STATUS_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<List<ApartmentModel>> getUserLikedApartments(
      {required String userId}) async {
    try {
      final likedApartments = await _supabaseClient
          .from('apartments')
          .select(
              '*, apartment_likes!apartment_likes_apartment_id_fkey!inner(*)')
          .eq('apartment_likes.user_id', userId)
          .eq('apartment_likes.is_liked', true)
          .then(
              (value) => value.map((e) => ApartmentModel.fromMap(e)).toList());
      return likedApartments;
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.GET_USER_LIKED_APARTMENTS_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.GET_USER_LIKED_APARTMENTS_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<void> changeApartmentAvailabilityStatus({
    required String userId,
    required String apartmentId,
    required bool isAvailable,
  }) async {
    try {
      await _supabaseClient
          .from('apartments')
          .update({
            'is_available': isAvailable,
          })
          .eq('id', apartmentId)
          .eq('user_id', userId);
      _logger.info(
          'Apartment ${isAvailable ? 'Shown' : 'Hidden'} successfully with id: $apartmentId');
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.CHANGE_APARTMENT_AVAILABILITY_STATUS_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.CHANGE_APARTMENT_AVAILABILITY_STATUS_ERR,
        e.toString(),
      );
    }
  }

  @override
  Future<void> deleteUserApartment({
    required String userId,
    required String apartmentId,
  }) async {
    try {
      await _supabaseClient
          .from('apartments')
          .delete()
          .eq('id', apartmentId)
          .eq('user_id', userId);
      _logger.info('Apartment deleted successfully with id: $apartmentId');
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.DELETE_APARTMENT_ERR,
        e.message,
      );
    } catch (e) {
      throw ApartmentErrorFactory.createApartmentError(
        ApartmentErrorCode.DELETE_APARTMENT_ERR,
        e.toString(),
      );
    }
  }
}
