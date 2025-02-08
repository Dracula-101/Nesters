import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/location/city_info.dart';
import 'package:nesters/domain/models/location/city_info_response.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/location/location_city.dart';
import 'package:nesters/domain/models/location/location_state.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/user/edit-profile/cubit/edit_profile_state.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  UserRepository({
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

  Future<void> setOnBoardingComplete() async {
    await _storageRepository.saveBool(
        LocalStorageKeys.userOnboardingComplete, true);
  }

  bool checkUserOnboardingStatus() {
    return _storageRepository
            .getBool(LocalStorageKeys.userOnboardingComplete) ??
        false;
  }

  bool checkUserTutorialComplete() {
    return _storageRepository.getBool(LocalStorageKeys.userTutorialComplete) ??
        false;
  }

  Future<void> markUserTutorialComplete() {
    return _storageRepository.saveBool(
        LocalStorageKeys.userTutorialComplete, true);
  }

  Future<List<MarketplaceModel>> getMarketplaceData() async {
    try {
      return await _databaseRepository.getData(
        "marketplace",
        orderBy: [OrderByKey(key: 'created_at', isDescending: true)],
      ).then(
          (event) => event.map((e) => MarketplaceModel.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting marketplace data: $e');
      rethrow;
    }
  }

  Future<List<University?>> getAllUniversities() async {
    return await _databaseRepository.getData(
      "universities",
      orderBy: [OrderByKey(key: 'title', isDescending: false)],
    ).then((event) => event.map((e) => University.fromJson(e)).toList());
  }

  Future<List<Degree?>> getAllDegrees() async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            masterDegreeCollection,
            FieldValue(key: 'title', value: ''),
          )
          .then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } catch (e) {
      return List.empty();
    }
  }

  Future<List<CityInfo>> searchCities({required String searchQuery}) async {
    String baseUrl =
        "https://api.thecompaniesapi.com/v2/locations/cities?search=$searchQuery";
    try {
      http.Response response = await http.get(Uri.parse(baseUrl));
      CityInfoResponse cityInfoResponse =
          CityInfoResponse.fromJson(jsonDecode(response.body));
      return CityInfo.fromResponse(cityInfoResponse);
    } catch (e) {
      return List.empty();
    }
  }

  List<String> getCountries() {
    return countries;
  }

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
      return false;
    }
  }

  Future<List<University>?> getUniversities(String? searchString) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            universityCollection,
            FieldValue(key: 'title', value: searchString ?? ''),
          )
          .then((event) => event.map((e) => University.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }

  Future<List<Degree>?> getMastersDegree(String? searchString) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            masterDegreeCollection,
            FieldValue(key: 'title', value: searchString ?? ''),
          )
          .then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }

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
    } catch (e) {
      return false;
    }
  }

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
    } catch (e) {
      return Future.value(false);
    }
  }

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

  Future<List<LocationState>> getIndianStates(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            indianStatesCollection,
            FieldValue(key: 'name', value: searchQuery ?? ''),
          )
          .then(
              (event) => event.map((e) => LocationState.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting states: $e');
      rethrow;
    }
  }

  Future<List<Language>> getLanguage(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
            indianLanguagesCollection,
            FieldValue(key: 'name', value: searchQuery ?? ''),
          )
          .then((event) => event.map((e) => Language.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting languages: $e');
      rethrow;
    }
  }

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
        ],
      ).then(
          (event) => event.map((e) => UserQuickProfile.fromJson(e!)).toList());
    } catch (e, stackTrace) {
      _logger.error('Error in getting user quick profiles: $e',
          stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<UserQuickProfile>> getSingleFilteredQuickProfiles(
      SingleUserFilter filter) async {
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
      ],
    ).then((event) => event.map((e) => UserQuickProfile.fromJson(e!)).toList());
  }

  Future<List<UserQuickProfile>> getMultipleFilteredQuickProfiles(
    UserFilter filters,
  ) async {
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
      ],
    ).then((value) {
      return value.map((e) => UserQuickProfile.fromJson(e ?? {})).toList();
    });
  }

  Future<UserProfile> getUserProfile(String id) async {
    try {
      UserProfile profile = await _databaseRepository
          .getDataWithId(
        userDetailCollection,
        FieldValue(key: 'id', value: id),
      )
          .then((event) {
        final user = event?.first;
        if (user == null) {
          throw Exception('User not found');
        }
        log("id: ${id}, User: ${user}");
        return UserProfile.fromJson(user);
      });
      return profile;
    } catch (e) {
      _logger.error('Error in getting user profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(UserEditProfile profile, String userId) async {
    try {
      return await _databaseRepository.updateData(
        userDetailCollection,
        UpdateData(columnId: "id", columnValue: userId, fields: [
          UpdateFieldValue(
              fieldName: "profile_image", newValue: profile.profileImage),
          UpdateFieldValue(
              fieldName: "selected_college_name",
              newValue: profile.selectedCollegeName),
          UpdateFieldValue(
              fieldName: "selected_course_name",
              newValue: profile.selectedCourseName),
          UpdateFieldValue(
              fieldName: "person_type",
              newValue: profile.personType.toString()),
          UpdateFieldValue(
              fieldName: "work_experience", newValue: profile.workExperience),
          UpdateFieldValue(
              fieldName: "smoking_habit",
              newValue: profile.smokingHabit.toString()),
          UpdateFieldValue(
              fieldName: "drinking_habit",
              newValue: profile.drinkingHabit.toString()),
          UpdateFieldValue(
              fieldName: "food_habit", newValue: profile.foodHabit.toString()),
          UpdateFieldValue(
              fieldName: "cooking_skill",
              newValue: profile.cookingSkill.toString()),
          UpdateFieldValue(
              fieldName: "cleanliness_habit",
              newValue: profile.cleanlinessHabit.toString()),
          UpdateFieldValue(fieldName: "bio", newValue: profile.bio),
          UpdateFieldValue(fieldName: "hobbies", newValue: profile.hobbies),
          UpdateFieldValue(
              fieldName: "flatmates_gender_prefs",
              newValue: profile.flatmatesGenderPrefs),
          UpdateFieldValue(
              fieldName: "room_type", newValue: profile.roomType.toUI()),
        ]),
      );
    } catch (e) {
      _logger.error('Error in updating user profile: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(
    String profileImagePath,
    String userId,
  ) async {
    try {
      final File imageFile = File(profileImagePath);
      final imageBytes = await imageFile.readAsBytes();
      final storageImagePath =
          '$userId/profile_image.${profileImagePath.split('.').last}';
      await _storageClient.from('profile_images').uploadBinary(
            storageImagePath,
            imageBytes,
            fileOptions: const FileOptions(
              upsert: true,
              cacheControl: '3600',
            ),
          );
      final imageUrl =
          _storageClient.from('profile_images').getPublicUrl(storageImagePath);
      return imageUrl;
    } catch (e) {
      _logger.error('Error in updating user profile image: $e');
      rethrow;
    }
  }

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
    } catch (e) {
      _logger.error('Error in deleting user account: $e');
      rethrow;
    }
  }
}

final List<String> countries = [
  "Afghanistan",
  "Albania",
  "Algeria",
  "Andorra",
  "Angola",
  "Antigua and Barbuda",
  "Argentina",
  "Armenia",
  "Australia",
  "Austria",
  "Azerbaijan",
  "Bahamas",
  "Bahrain",
  "Bangladesh",
  "Barbados",
  "Belarus",
  "Belgium",
  "Belize",
  "Benin",
  "Bhutan",
  "Bolivia",
  "Bosnia and Herzegovina",
  "Botswana",
  "Brazil",
  "Brunei",
  "Bulgaria",
  "Burkina Faso",
  "Burundi",
  "Cabo Verde",
  "Cambodia",
  "Cameroon",
  "Canada",
  "Central African Republic",
  "Chad",
  "Chile",
  "China",
  "Colombia",
  "Comoros",
  "Congo (Congo-Brazzaville)",
  "Costa Rica",
  "Croatia",
  "Cuba",
  "Cyprus",
  "Czechia (Czech Republic)",
  "Denmark",
  "Djibouti",
  "Dominica",
  "Dominican Republic",
  "Ecuador",
  "Egypt",
  "El Salvador",
  "Equatorial Guinea",
  "Eritrea",
  "Estonia",
  "Eswatini (fmr. \"Swaziland\")",
  "Ethiopia",
  "Fiji",
  "Finland",
  "France",
  "Gabon",
  "Gambia",
  "Georgia",
  "Germany",
  "Ghana",
  "Greece",
  "Grenada",
  "Guatemala",
  "Guinea",
  "Guinea-Bissau",
  "Guyana",
  "Haiti",
  "Honduras",
  "Hungary",
  "Iceland",
  "India",
  "Indonesia",
  "Iran",
  "Iraq",
  "Ireland",
  "Israel",
  "Italy",
  "Jamaica",
  "Japan",
  "Jordan",
  "Kazakhstan",
  "Kenya",
  "Kiribati",
  "Kuwait",
  "Kyrgyzstan",
  "Laos",
  "Latvia",
  "Lebanon",
  "Lesotho",
  "Liberia",
  "Libya",
  "Liechtenstein",
  "Lithuania",
  "Luxembourg",
  "Madagascar",
  "Malawi",
  "Malaysia",
  "Maldives",
  "Mali",
  "Malta",
  "Marshall Islands",
  "Mauritania",
  "Mauritius",
  "Mexico",
  "Micronesia",
  "Moldova",
  "Monaco",
  "Mongolia",
  "Montenegro",
  "Morocco",
  "Mozambique",
  "Myanmar (Burma)",
  "Namibia",
  "Nauru",
  "Nepal",
  "Netherlands",
  "New Zealand",
  "Nicaragua",
  "Niger",
  "Nigeria",
  "North Korea",
  "North Macedonia",
  "Norway",
  "Oman",
  "Pakistan",
  "Palau",
  "Palestine State",
  "Panama",
  "Papua New Guinea",
  "Paraguay",
  "Peru",
  "Philippines",
  "Poland",
  "Portugal",
  "Qatar",
  "Romania",
  "Russia",
  "Rwanda",
  "Saint Kitts and Nevis",
  "Saint Lucia",
  "Saint Vincent and the Grenadines",
  "Samoa",
  "San Marino",
  "Sao Tome and Principe",
  "Saudi Arabia",
  "Senegal",
  "Serbia",
  "Seychelles",
  "Sierra Leone",
  "Singapore",
  "Slovakia",
  "Slovenia",
  "Solomon Islands",
  "Somalia",
  "South Africa",
  "South Korea",
  "South Sudan",
  "Spain",
  "Sri Lanka",
  "Sudan",
  "Suriname",
  "Sweden",
  "Switzerland",
  "Syria",
  "Tajikistan",
  "Tanzania",
  "Thailand",
  "Timor-Leste",
  "Togo",
  "Tonga",
  "Trinidad and Tobago",
  "Tunisia",
  "Turkey",
  "Turkmenistan",
  "Tuvalu",
  "Uganda",
  "Ukraine",
  "United Arab Emirates",
  "United Kingdom",
  "United States of America",
  "Uruguay",
  "Uzbekistan",
  "Vanuatu",
  "Vatican City",
  "Venezuela",
  "Vietnam",
  "Yemen",
  "Zambia",
  "Zimbabwe",
];
