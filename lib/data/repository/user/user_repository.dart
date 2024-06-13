import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/domain/models/college/degree.dart';
import 'package:nesters/domain/models/college/university.dart';
import 'package:nesters/domain/models/location/indian_city.dart';
import 'package:nesters/domain/models/location/indian_state.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/user/form/user_basic_profile.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/utils/logger/logger.dart';

class UserRepository {
  UserRepository({
    required DatabaseRepository databaseRepository,
    required LocalStorageRepository storageRepository,
    required AppLogger logger,
    // required FirestoreRepository firestoreRepository,
  })  : _databaseRepository = databaseRepository,
        _storageRepository = storageRepository,
        _logger = logger;

  final DatabaseRepository _databaseRepository;
  final LocalStorageRepository _storageRepository;
  final AppLogger _logger;

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

  Future<List<University?>> getAllUniversities() async {
    return Future.value(List.empty());
  }

  Future<List<Degree?>> getAllDegrees() async {
    return Future.value(List.empty());
  }

  Future<bool?> checkUserCreated(String userId) async {
    try {
      return await _databaseRepository.checkExistsData(
        userDetailCollection,
        FieldValue(
          key: 'id',
          value: userId,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<University>?> getUniversities(String? searchString) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
              universityCollection, 'title', searchString ?? '')
          .then((event) => event.map((e) => University.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }

  Future<List<Degree>?> getMastersDegree(String? searchString) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
              masterDegreeCollection, 'title', searchString ?? '')
          .then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }

  Future<void> setBasicUserProfileData(UserBasicProfile userProfile) async {
    try {
      return await _databaseRepository.setData(
        userDetailCollection,
        SetData(
          fields: userProfile.toFieldValues(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<City>> getCites(String searchQuery) {
    try {
      return _databaseRepository
          .searchDataFromFuture(indianCitiesCollection, 'name', searchQuery)
          .asStream()
          .map((event) => event.map((e) => City.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting cities: $e');
      return Stream.value([]);
    }
  }

  Future<List<IndianState>> getIndianStates(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
              indianStatesCollection, 'name', searchQuery ?? '')
          .then((event) => event.map((e) => IndianState.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting states: $e');
      rethrow;
    }
  }

  Future<List<Language>> getLanguage(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture(
              indianLanguagesCollection, 'name', searchQuery ?? '')
          .then((event) => event.map((e) => Language.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting languages: $e');
      rethrow;
    }
  }

  Future<List<UserQuickProfile>> getUserQuickProfiles(
      int offset, int limit, String userId) async {
    try {
      return await _databaseRepository
          .getDataWithPagination(userDetailCollection, offset, limit,
              columns:
                  'id, full_name, profile_image, selected_college_name, selected_course_name, city, state, work_experience',
              removeRowId: userId)
          .then((event) =>
              event.map((e) => UserQuickProfile.fromJson(e!)).toList());
    } catch (e, stackTrace) {
      _logger.error('Error in getting user quick profiles: $e',
          stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<UserProfile> getUserProfile(String id) async {
    try {
      UserProfile profile = await _databaseRepository
          .getDataWithId(userDetailCollection, id)
          .then((event) => UserProfile.fromJson(event!));
      return profile;
    } catch (e) {
      _logger.error('Error in getting user profile: $e');
      rethrow;
    }
  }
}
