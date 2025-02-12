import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/error/local_storage_error.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/data/repository/database/remote/error/database_error.dart';
import 'package:nesters/data/repository/user/error/user_error.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/location/city_info.dart';
import 'package:nesters/domain/models/location/city_info_response.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/location/location_city.dart';
import 'package:nesters/domain/models/location/location_state.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/user/form/user_advance_profile.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/user/edit-profile/cubit/edit_profile_state.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required AuthRepository authRepository,
    required DatabaseRepository databaseRepository,
    required LocalStorageRepository storageRepository,
    required AppLogger logger,
    // required FirestoreRepository firestoreRepository,
  })  : _authRepository = authRepository,
        _databaseRepository = databaseRepository,
        _storageRepository = storageRepository,
        _logger = logger;

  final AuthRepository _authRepository;
  final DatabaseRepository _databaseRepository;
  final LocalStorageRepository _storageRepository;
  final AppLogger _logger;
  final SupabaseStorageClient _storageClient = Supabase.instance.client.storage;

  String universityCollection = "universities";
  String masterDegreeCollection = "masters";
  String indianCitiesCollection = "indian_cities";
  String indianStatesCollection = "indian_states";
  String userDetailCollection = "user_details";
  String indianLanguagesCollection = "indian_languages";

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
    return _storageRepository.getBool(LocalStorageKeys.userTutorialComplete) ??
        false;
  }

  @override
  Future<void> markUserTutorialComplete() {
    return _storageRepository.saveBool(
        LocalStorageKeys.userTutorialComplete, true);
  }

  @override
  Future<List<MarketplaceModel>> getMarketplaceData() async {
    try {
      return await _databaseRepository.getData(
        "marketplace",
        orderBy: [OrderByKey(key: 'created_at', isDescending: true)],
      ).then(
          (event) => event.map((e) => MarketplaceModel.fromJson(e)).toList());
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting marketplace data');
    }
  }

  @override
  Future<List<University>> getAllUniversities() async {
    try {
      return await _databaseRepository.getData(
        "universities",
        orderBy: [OrderByKey(key: 'title', isDescending: false)],
      ).then((event) => event.map((e) => University.fromJson(e)).toList());
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting universities');
    }
  }

  @override
  Future<List<Degree>> getAllDegrees() async {
    try {
      return await _databaseRepository.getData(
        "masters",
        orderBy: [OrderByKey(key: 'title', isDescending: false)],
      ).then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } catch (e) {
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
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting cities');
    }
  }

  @override
  Future<bool?> checkUserCreated(String userId) async {
    try {
      return await _databaseRepository.checkExistsData(
        userDetailCollection,
        [
          FieldValue(
            key: 'id',
            value: userId,
          ),
          FieldValue(
            key: 'user_deleted',
            value: false,
          ),
        ],
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<University>> getUniversities(String? searchString) async {
    return await _databaseRepository
        .searchDataFromFuture(
          universityCollection,
          FieldValue(key: 'title', value: searchString ?? ''),
        )
        .then((event) => event.map((e) => University.fromJson(e)).toList());
  }

  @override
  Future<List<Degree>> getMastersDegree(String? searchString) async {
    return await _databaseRepository
        .searchDataFromFuture(
          masterDegreeCollection,
          FieldValue(key: 'title', value: searchString ?? ''),
        )
        .then((event) => event.map((e) => Degree.fromJson(e)).toList());
  }

  @override
  Future<bool> setBasicUserProfileData(UserBasicProfile userProfile) async {
    try {
      bool isUserDeleted = userProfile.email == null
          ? false
          : await hasUserDeletedAccount(
              email: userProfile.email!,
            );
      await _databaseRepository.setData(
        userDetailCollection,
        SetData(
          fields: userProfile.toFieldValues(
            includeUserDeleteUpdate: isUserDeleted,
          ),
        ),
      );
      await _storageRepository.saveBool(
        LocalStorageKeys.userProfileCreated,
        true,
      );
      return true;
    } on SocketException {
      throw NoNetworkError();
    } on LocalStorageError {
      throw UserBasicInfoError(message: 'Error setting user profile');
    } on DatabaseError {
      throw UserBasicInfoError(
        message: 'Error setting values in DB',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UserBasicInfoError(message: 'Error setting user profile');
    }
  }

  @override
  Future<bool> hasUserDeletedAccount({required String email}) {
    try {
      return _databaseRepository.checkExistsData(
        userDetailCollection,
        [
          FieldValue(
            key: 'email',
            value: email,
          ),
          FieldValue(
            key: 'user_deleted',
            value: true,
          ),
        ],
      );
    } on SocketException {
      throw NoNetworkError();
    } on DatabaseError {
      throw UserBasicInfoError(
        message: 'Error checking user deleted status',
      );
    } catch (e) {
      throw UserBasicInfoError(
        message: 'Error checking user deleted status',
      );
    }
  }

  @override
  Future<void> updateRoommateFoundStatus(
      {required String id, required bool status}) {
    try {
      return _databaseRepository.updateData(
        userDetailCollection,
        UpdateData(
          columnId: "id",
          columnValue: id,
          fields: [
            UpdateFieldValue(
              fieldName: "has_roommate_found",
              newValue: status,
            ),
          ],
        ),
      );
    } on SocketException {
      throw NoNetworkError();
    } on DatabaseError {
      throw UserBasicInfoError(
        message: 'Error updating roommate found status',
      );
    } catch (e) {
      throw UserBasicInfoError(
        message: 'Error updating roommate found status',
      );
    }
  }

  @override
  Stream<List<LocationCity>> getCites(String searchQuery) {
    try {
      return _databaseRepository
          .searchDataFromFuture(
            indianCitiesCollection,
            FieldValue(key: 'name', value: searchQuery),
          )
          .asStream()
          .map((event) => event.map((e) => LocationCity.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting cities: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<List<LocationState>> getIndianStates(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            indianStatesCollection,
            FieldValue(key: 'name', value: searchQuery ?? ''),
          )
          .then(
              (event) => event.map((e) => LocationState.fromJson(e)).toList());
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting states');
    }
  }

  @override
  Future<List<Language>> getLanguage(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            indianLanguagesCollection,
            FieldValue(key: 'name', value: searchQuery ?? ''),
          )
          .then((event) => event.map((e) => Language.fromJson(e)).toList());
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting languages');
    }
  }

  @override
  Future<List<UserQuickProfile>> getUserQuickProfiles(
      int offset, int limit, String userId) async {
    try {
      return await _databaseRepository.getDataWithPagination(
        userDetailCollection,
        offset,
        limit,
        orderBy: [OrderByKey(key: 'created_at', isDescending: true)],
        columns: [
          DbKey(key: 'id'),
          DbKey(key: 'full_name'),
          DbKey(key: 'profile_image'),
          DbKey(key: 'selected_college_name'),
          DbKey(key: 'selected_course_name'),
          DbKey(key: 'city'),
          DbKey(key: 'state'),
          DbKey(key: 'work_experience'),
          DbKey(key: 'intake_period'),
          DbKey(key: 'intake_year'),
        ],
        whereNotFields: [
          FieldValue(
            key: 'id',
            value: userId,
          ),
          FieldValue(
            key: 'user_deleted',
            value: true,
          ),
          FieldValue(
            key: 'has_roommate_found',
            value: true,
          ),
        ],
      ).then(
          (event) => event.map((e) => UserQuickProfile.fromJson(e!)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting user profiles');
    }
  }

  @override
  Future<List<UserQuickProfile>> getSingleFilteredQuickProfiles(
      SingleUserFilter filter) async {
    try {
      QueryData? query;
      if (filter is UniversityFilter) {
        query = QueryData(
          fieldName: 'selected_college_name',
          equalTo: FieldValue(
            key: 'selected_college_name',
            value: filter.university,
          ),
        );
      } else if (filter is BranchFilter) {
        query = QueryData(
          fieldName: 'selected_course_name',
          equalTo: FieldValue(
            key: 'selected_course_name',
            value: filter.branch,
          ),
        );
      } else if (filter is GenderFilter) {
        query = QueryData(
          fieldName: 'gender',
          equalTo: FieldValue(
            key: 'gender',
            value: filter.gender,
          ),
        );
      }
      if (query == null) {
        throw Exception('Invalid filter type');
      }
      final userId = _authRepository.currentUser?.id;
      return await _databaseRepository.getFilteredData(
        userDetailCollection,
        query,
        orderBy: [OrderByKey(key: 'created_at', isDescending: true)],
        columns: [
          DbKey(key: 'id'),
          DbKey(key: 'full_name'),
          DbKey(key: 'profile_image'),
          DbKey(key: 'selected_college_name'),
          DbKey(key: 'selected_course_name'),
          DbKey(key: 'city'),
          DbKey(key: 'state'),
          DbKey(key: 'work_experience'),
          DbKey(key: 'intake_period'),
          DbKey(key: 'intake_year'),
        ],
        whereNotFields: [
          FieldValue(
            key: 'id',
            value: userId,
          ),
          FieldValue(
            key: 'user_deleted',
            value: true,
          ),
          FieldValue(
            key: 'has_roommate_found',
            value: true,
          ),
        ],
      ).then(
          (event) => event.map((e) => UserQuickProfile.fromJson(e!)).toList());
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting user profiles');
    }
  }

  @override
  Future<List<UserQuickProfile>> getMultipleFilteredQuickProfiles(
    UserFilter filters,
  ) async {
    try {
      List<QueryData> query = [];
      if (filters.universityName != null && filters.universityName != "") {
        query.add(
          QueryData(
            fieldName: 'selected_college_name',
            equalTo: FieldValue(
              key: 'selected_college_name',
              value: filters.universityName,
            ),
          ),
        );
      }
      if (filters.branchName != null && filters.branchName != "") {
        query.add(
          QueryData(
            fieldName: 'selected_course_name',
            equalTo: FieldValue(
              key: 'selected_course_name',
              value: filters.branchName,
            ),
          ),
        );
      }
      if (filters.intakePeriod != null && filters.intakePeriod != "") {
        query.add(
          QueryData(
            fieldName: 'intake_period',
            equalTo: FieldValue(
              key: 'intake_period',
              value: filters.intakePeriod,
            ),
          ),
        );
      }
      if (filters.intakeYear != null) {
        query.add(
          QueryData(
            fieldName: 'intake_year',
            equalTo: FieldValue(
              key: 'intake_year',
              value: filters.intakeYear,
            ),
          ),
        );
      }
      if (filters.drinkingHabit != null &&
          filters.drinkingHabit != UserHabit.UNKNOWN) {
        query.add(
          QueryData(
            fieldName: "drinking_habit",
            equalTo: FieldValue(
              key: "drinking_habit",
              value: filters.drinkingHabit,
            ),
          ),
        );
      }
      if (filters.smokingHabit != null &&
          filters.smokingHabit != UserHabit.UNKNOWN) {
        query.add(
          QueryData(
            fieldName: "smoking_habit",
            equalTo: FieldValue(
              key: "smoking_habit",
              value: filters.smokingHabit,
            ),
          ),
        );
      }
      if (filters.personType != null &&
          filters.personType != PersonType.UNKNOWN) {
        query.add(
          QueryData(
            fieldName: "person_type",
            equalTo: FieldValue(
              key: "person_type",
              value: filters.personType,
            ),
          ),
        );
      }
      if (filters.flatmateGenderPref != null &&
          filters.flatmateGenderPref != "") {
        query.add(
          QueryData(
            fieldName: "gender",
            equalTo: FieldValue(
              key: "gender",
              value: filters.flatmateGenderPref,
            ),
          ),
        );
      }
      final userId = _authRepository.currentUser?.id;
      return await _databaseRepository.getMultipleFilteredData(
        userDetailCollection,
        query,
        orderBy: [OrderByKey(key: 'created_at', isDescending: true)],
        columns: [
          DbKey(key: 'id'),
          DbKey(key: 'full_name'),
          DbKey(key: 'profile_image'),
          DbKey(key: 'selected_college_name'),
          DbKey(key: 'selected_course_name'),
          DbKey(key: 'city'),
          DbKey(key: 'state'),
          DbKey(key: 'gender'),
          DbKey(key: 'work_experience'),
          DbKey(key: 'intake_period'),
          DbKey(key: 'intake_year'),
        ],
        whereNotFields: [
          FieldValue(
            key: 'id',
            value: userId,
          ),
          FieldValue(
            key: 'user_deleted',
            value: true,
          ),
          FieldValue(
            key: 'has_roommate_found',
            value: true,
          ),
        ],
      ).then((value) {
        return value.map((e) => UserQuickProfile.fromJson(e ?? {})).toList();
      });
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting user profiles');
    }
  }

  Future<UserInfo> getUserInfoProfile() {
    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) {
        throw Exception('User not found');
      }
      return _databaseRepository
          .getDataWithId(
            userDetailCollection,
            FieldValue(key: 'id', value: userId),
          )
          .then((value) => UserInfo.fromJson(value?.first ?? {}));
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting user profile');
    }
  }

  @override
  Future<UserProfile> getUserProfile(String userId) {
    try {
      return _databaseRepository
          .getDataWithId(
            userDetailCollection,
            FieldValue(key: 'id', value: userId),
          )
          .then((value) => UserProfile.fromJson(value?.first ?? {}));
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting user profile');
    }
  }

  @override
  Future<UserAdvanceProfile> getUserFullProfile(String userId) {
    try {
      return _databaseRepository
          .getDataWithId(
            userDetailCollection,
            FieldValue(key: 'id', value: userId),
          )
          .then((value) => UserAdvanceProfile.fromJson(value?.first ?? {}));
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw GetUserInfoError(message: 'Error in getting user profile');
    }
  }

  @override
  Future<void> updateProfile(UserEditProfile profile, String userId) async {
    try {
      return await _databaseRepository.updateData(
        userDetailCollection,
        UpdateData(
          columnId: "id",
          columnValue: userId,
          fields: [
            UpdateFieldValue(
              fieldName: "profile_image",
              newValue: profile.profileImage,
            ),
            UpdateFieldValue(
              fieldName: "selected_college_name",
              newValue: profile.selectedCollegeName,
            ),
            UpdateFieldValue(
              fieldName: "selected_course_name",
              newValue: profile.selectedCourseName,
            ),
            UpdateFieldValue(
              fieldName: "person_type",
              newValue: profile.personType.toString(),
            ),
            UpdateFieldValue(
              fieldName: "work_experience",
              newValue: profile.workExperience,
            ),
            UpdateFieldValue(
              fieldName: "smoking_habit",
              newValue: profile.smokingHabit.toString(),
            ),
            UpdateFieldValue(
              fieldName: "drinking_habit",
              newValue: profile.drinkingHabit.toString(),
            ),
            UpdateFieldValue(
              fieldName: "food_habit",
              newValue: profile.foodHabit.toString(),
            ),
            UpdateFieldValue(
              fieldName: "cooking_skill",
              newValue: profile.cookingSkill.toString(),
            ),
            UpdateFieldValue(
              fieldName: "cleanliness_habit",
              newValue: profile.cleanlinessHabit.toString(),
            ),
            UpdateFieldValue(
              fieldName: "bio",
              newValue: profile.bio,
            ),
            UpdateFieldValue(
              fieldName: "hobbies",
              newValue: profile.hobbies,
            ),
            UpdateFieldValue(
                fieldName: "flatmates_gender_prefs",
                newValue: profile.flatmatesGenderPrefs),
            UpdateFieldValue(
              fieldName: "room_type",
              newValue: profile.roomType.toUI(),
            ),
            UpdateFieldValue(
              fieldName: "intake_period",
              newValue: profile.intakePeriod,
            ),
            UpdateFieldValue(
              fieldName: "intake_year",
              newValue: profile.intakeYear,
            ),
          ],
        ),
      );
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
      if (userId == null) {
        throw Exception('User not found');
      }
      return _databaseRepository.updateData(
        userDetailCollection,
        UpdateData(
          columnId: "id",
          columnValue: userId,
          fields: [
            UpdateFieldValue(fieldName: "user_deleted", newValue: true),
            UpdateFieldValue(
                fieldName: "user_deleted_date",
                newValue: DateTime.now().toIso8601String()),
          ],
        ),
      );
    } on SocketException {
      throw NoNetworkError();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UserDeleteError(message: 'Error in deleting user account');
    }
  }
}
