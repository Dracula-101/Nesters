import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:google_places_sdk/google_places_sdk.dart';
import 'package:http/http.dart' as http;

import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/error/local_storage_error.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/network/network_error.dart';
import 'package:nesters/data/repository/user/error/user_error.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/location/city_info.dart';
import 'package:nesters/domain/models/location/city_info_response.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/user/address.dart';
import 'package:nesters/domain/models/user/form/user_advance_profile.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/user/edit-profile/cubit/edit_profile_state.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required AuthRepository authRepository,
    required LocalStorageRepository storageRepository,
    required AppLogger logger,
    required GooglePlaces placesRepository,
  })  : _authRepository = authRepository,
        _storageRepository = storageRepository,
        _logger = logger,
        _placesRepository = placesRepository;

  final AuthRepository _authRepository;
  final LocalStorageRepository _storageRepository;
  final GooglePlaces _placesRepository;
  final AppLogger _logger;
  final SupabaseStorageClient _storageClient = Supabase.instance.client.storage;
  final SupabaseClient _supabase = Supabase.instance.client;

  final String constSchema = "const";
  final String universityTable = 'universities';
  final String masterDegreeTable = "degrees";
  final String marketplaceTable = "marketplace";
  final String languageTable = "languages";

  final String userDetailTable = "user_details";

  @override
  Future<void> setOnBoardingComplete() async {
    await _storageRepository.saveBool(
        LocalStorageKeys.userOnboardingComplete, true);
  }

  @override
  bool checkUserOnboardingStatus() {
    return _storageRepository
            .getBool(LocalStorageKeys.userOnboardingComplete) ??
        false;
  }

  @override
  bool checkUserTutorialComplete() {
    return _authRepository.currentUserInfo?.profileCompleted == true ||
        (_storageRepository.getBool(LocalStorageKeys.userTutorialComplete) ??
            false);
  }

  @override
  Future<void> markUserTutorialComplete() {
    return _storageRepository.saveBool(
        LocalStorageKeys.userTutorialComplete, true);
  }

  @override
  bool checkSettingInfoComplete() {
    final currentTimesShown =
        _storageRepository.getInt(LocalStorageKeys.settingInfoStatus) ?? 0;
    return currentTimesShown >= 3;
  }

  @override
  Future<void> updateSettingInfoStatus() {
    final currentTimesShown =
        _storageRepository.getInt(LocalStorageKeys.settingInfoStatus) ?? 0;
    return _storageRepository.saveInt(
        LocalStorageKeys.settingInfoStatus, currentTimesShown + 1);
  }

  @override
  Future<List<MarketplaceModel>> getMarketplaceData() async {
    try {
      return _supabase
          .from(marketplaceTable)
          .select()
          .order('created_at', ascending: false)
          .then((event) =>
              event.map((e) => MarketplaceModel.fromJson(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting marketplace data');
    }
  }

  @override
  Future<List<University>> getAllUniversities() async {
    try {
      return _supabase
          .schema(constSchema)
          .from(universityTable)
          .select()
          .order('title', ascending: true)
          .then((event) =>
              event.map((e) => University.fromJson(e['id'], json: e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting universities');
    }
  }

  @override
  Future<List<Degree>> getAllDegrees() async {
    try {
      return _supabase
          .schema(constSchema)
          .from(masterDegreeTable)
          .select()
          .order('title', ascending: true)
          .then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting degrees');
    }
  }

  @override
  Future<List<CityInfo>> searchCities({required String searchQuery}) async {
    try {
      String baseUrl =
          "https://api.thecompaniesapi.com/v2/locations/cities?search=$searchQuery";
      http.Response response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode != 200) {
        throw GetUserInfoError(message: 'Error in getting cities');
      }
      CityInfoResponse cityInfoResponse =
          CityInfoResponse.fromJson(jsonDecode(response.body));
      return CityInfo.fromResponse(cityInfoResponse);
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting cities');
    }
  }

  @override
  Future<bool?> checkUserCreated(String userId) async {
    try {
      final result = await _supabase
          .from(userDetailTable)
          .select()
          .eq('id', userId)
          .limit(1);
      if (result.isEmpty) return false;
      return true;
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      return null;
    }
  }

  @override
  Future<List<University>> getUniversities(String? searchString) async {
    try {
      return _supabase.schema(constSchema).from(universityTable).select().then(
          (event) =>
              event.map((e) => University.fromJson(e['id'], json: e)).toList());
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting universities');
    }
  }

  @override
  Future<List<Language>> getLanguage(String? searchQuery) async {
    try {
      return _supabase
          .schema(constSchema)
          .from(languageTable)
          .select()
          .then((event) => event.map((e) => Language.fromJson(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting languages');
    }
  }

  @override
  Future<List<Language>> getLanguages() async {
    try {
      return _supabase
          .schema(constSchema)
          .from(languageTable)
          .select()
          .then((event) => event.map((e) => Language.fromJson(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting languages');
    }
  }

  @override
  Future<List<SearchAddress>> searchAddress(String? searchQuery) async {
    try {
      final places =
          await _placesRepository.getAutoCompletePredictions(searchQuery!);
      return places.map((e) => SearchAddress.fromPrediction(e)).toList();
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting addresses');
    }
  }

  @override
  Future<List<Degree>> getMastersDegree(String? searchString) async {
    try {
      return _supabase
          .schema(constSchema)
          .from(masterDegreeTable)
          .select()
          .then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting degrees');
    }
  }

  @override
  Future<bool> setBasicUserProfileData(UserBasicProfile userProfile) async {
    try {
      await _supabase.from(userDetailTable).upsert({
        ...userProfile.toJson(),
        'user_deleted': false,
      });
      await _storageRepository.saveBool(
        LocalStorageKeys.userProfileCreated,
        true,
      );
      return true;
    } on SocketException {
      throw NoNetworkError();
    } on LocalStorageError {
      throw UserBasicInfoError(message: 'Error setting user profile');
    } on AppException {
      rethrow;
    } catch (e) {
      throw UserBasicInfoError(message: 'Error setting user profile');
    }
  }

  @override
  Future<bool> hasUserDeletedAccount({required String email}) async {
    try {
      final result = _supabase
          .from(userDetailTable)
          .select()
          .eq('email', email)
          .eq('user_deleted', true)
          .limit(1);
      return result.then((value) => value.isNotEmpty);
    } on SocketException {
      throw NoNetworkError();
    } on Exception {
      throw UserBasicInfoError(
        message: 'Error checking user deleted status',
      );
    }
  }

  @override
  Future<void> updateRoommateFoundStatus(
      {required String id, required bool status}) async {
    try {
      return _supabase.from(userDetailTable).update({
        'has_roommate_found': status,
      }).eq('id', id);
    } on SocketException {
      throw NoNetworkError();
    } on Exception {
      throw UserBasicInfoError(
        message: 'Error updating roommate found status',
      );
    }
  }

  @override
  Future<List<UserQuickProfile>> getUserQuickProfiles(
      int offset, int limit, String userId) async {
    try {
      return _supabase
          .from(userDetailTable)
          .select()
          .neq('id', userId)
          .neq('user_deleted', true)
          .neq('has_roommate_found', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit)
          .then((e) => e.map((e) => UserQuickProfile.fromJson(e)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      log(e.toString());
      throw GetUserInfoError(message: 'Error in getting user profiles');
    }
  }

  @override
  Future<List<UserQuickProfile>> getSingleFilteredQuickProfiles(
      SingleUserFilter filter) async {
    try {
      PostgrestFilterBuilder queryBuilder =
          _supabase.from(userDetailTable).select();
      if (filter is UniversityFilter) {
        queryBuilder =
            queryBuilder.eq('college', filter.university.title ?? '');
      } else if (filter is BranchFilter) {
        queryBuilder = queryBuilder.eq('selected_course_name', filter.branch);
      } else if (filter is GenderFilter) {
        queryBuilder = queryBuilder.eq('gender', filter.gender);
      }
      final userId = _authRepository.currentUser?.id;
      if (userId == null) throw UserNotAuthError();
      final filterResults = await queryBuilder
          .neq('id', userId)
          .neq('user_deleted', true)
          .neq('has_roommate_found', true)
          .order('created_at', ascending: true)
          .select();
      return filterResults.isNotEmpty
          ? filterResults.map((e) => UserQuickProfile.fromJson(e)).toList()
          : [];
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      log(e.toString());
      throw GetUserInfoError(message: 'Error in getting user profiles');
    }
  }

  @override
  Future<List<UserQuickProfile>> getMultipleFilteredQuickProfiles(
    UserFilter filters,
  ) async {
    try {
      PostgrestFilterBuilder queryBuilder =
          _supabase.from(userDetailTable).select();
      if (filters.university != null && filters.university?.id != null) {
        queryBuilder =
            queryBuilder.eq('college', filters.university!.title ?? '');
      }
      if (filters.branchName != null && filters.branchName != "") {
        queryBuilder =
            queryBuilder.eq('selected_course_name', filters.branchName!);
      }
      if (filters.intakePeriod != null &&
          filters.intakePeriod != UserIntake.UNKNOWN) {
        queryBuilder = queryBuilder.eq('intake_period', filters.intakePeriod!);
      }
      if (filters.intakeYear != null) {
        queryBuilder = queryBuilder.eq('intake_year', filters.intakeYear!);
      }
      if (filters.drinkingHabit != null &&
          filters.drinkingHabit != UserHabit.UNKNOWN) {
        queryBuilder =
            queryBuilder.eq('drinking_habit', filters.drinkingHabit.toString());
      }
      if (filters.smokingHabit != null &&
          filters.smokingHabit != UserHabit.UNKNOWN) {
        queryBuilder =
            queryBuilder.eq('smoking_habit', filters.smokingHabit.toString());
      }
      if (filters.personType != null &&
          filters.personType != PersonType.UNKNOWN) {
        queryBuilder =
            queryBuilder.eq('person_type', filters.personType.toString());
      }
      if (filters.flatmateGenderPref != null &&
          filters.flatmateGenderPref != "") {
        queryBuilder = queryBuilder.eq(
            'flatmates_gender_prefs', filters.flatmateGenderPref!);
      }
      final userId = _authRepository.currentUser?.id;
      if (userId == null) throw UserNotAuthError();
      final filterResults = await queryBuilder
          .neq('id', userId)
          .neq('user_deleted', true)
          .neq('has_roommate_found', true)
          .order('created_at', ascending: true)
          .select();
      return filterResults.isNotEmpty
          ? filterResults.map((e) => UserQuickProfile.fromJson(e)).toList()
          : [];
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      log(e.toString());
      throw GetUserInfoError(message: 'Error in getting user profiles');
    }
  }

  Future<UserInfo> getUserInfoProfile() async {
    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) {
        throw UserNotAuthError();
      }
      return _supabase
          .from(userDetailTable)
          .select()
          .eq('id', userId)
          .single()
          .then((value) => UserInfo.fromJson(value));
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting user profile');
    }
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      return _supabase
          .from(userDetailTable)
          .select()
          .eq('id', userId)
          .single()
          .then((value) => UserProfile.fromJson(value));
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting user profile');
    }
  }

  @override
  Future<UserAdvanceProfile> getUserFullProfile(String userId) async {
    try {
      return _supabase
          .from(userDetailTable)
          .select()
          .eq('id', userId)
          .single()
          .then((value) => UserAdvanceProfile.fromJson(value));
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw GetUserInfoError(message: 'Error in getting user profile');
    }
  }

  @override
  Future<void> completeProfileInfo(UserFormProfile profile) async {
    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) throw UserNotAuthError();
      return _supabase.from(userDetailTable).upsert({
        ...profile.toMap(),
        'id': userId,
      });
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw UpdateUserInfoError(message: 'Error in updating user profile');
    }
  }

  @override
  Future<void> editProfile(UserEditProfile profile, String userId) async {
    try {
      return _supabase.from(userDetailTable).upsert({
        ...profile.toMap(),
        'id': userId,
      });
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UpdateUserInfoError(message: 'Error in updating user profile');
    }
  }

  @override
  Future<String> uploadProfileImage(
    String profileImagePath,
    String userId, {
    String? previousImageUrl,
  }) async {
    try {
      final File imageFile = File(profileImagePath);
      final imageBytes = await imageFile.readAsBytes();
      final dateEpoch = DateTime.now().millisecondsSinceEpoch;
      final storageImagePath =
          '$userId/profile_image_$dateEpoch.${profileImagePath.split('.').last}';
      if (previousImageUrl != null) {
        String previousImageName = previousImageUrl.split('/').last;
        await _storageClient
            .from('profile_images')
            .remove(["$userId/$previousImageName"]);
      }
      await _storageClient.from('profile_images').uploadBinary(
            storageImagePath,
            imageBytes,
            retryAttempts: 5,
          );
      final imageUrl =
          _storageClient.from('profile_images').getPublicUrl(storageImagePath);
      return imageUrl;
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      _logger.error('Error in uploading profile image: $e');
      throw UploadUserImageError(message: 'Error in uploading user image');
    }
  }

  @override
  Future<void> softDeleteAccount() {
    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) throw UserNotAuthError();
      return _supabase.from(userDetailTable).update({
        'user_deleted': true,
      }).eq('id', userId);
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } on Exception {
      throw UserDeleteError(message: 'Error in deleting user account');
    }
  }
}
