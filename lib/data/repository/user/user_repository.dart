import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/domain/models/city.dart';
import 'package:nesters/domain/models/degree.dart';
import 'package:nesters/domain/models/indian_state.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/university.dart';
import 'package:nesters/domain/models/user_basic_profile.dart';
import 'package:nesters/utils/logger/logger.dart';

class UserRepository {
  UserRepository({
    required DatabaseRepository databaseRepository,
    required LocalStorageRepository storageRepository,
    required AppLoggerService logger,
    // required FirestoreRepository firestoreRepository,
  })  : _databaseRepository = databaseRepository,
        _storageRepository = storageRepository,
        _logger = logger;

  final DatabaseRepository _databaseRepository;
  final LocalStorageRepository _storageRepository;
  final AppLoggerService _logger;

  String universityCollection = "universities";
  String masterDegreeCollection = "masters";

  Future<void> setOnBoardingComplete() async {
    await _storageRepository.saveBool(
        LocalStorageKeys.userOnboardingComplete, true);
  }

  Future<bool> checkUserOnboardingStatus() async {
    return await _storageRepository
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
        'user_details',
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
          .searchDataFromFuture('universities', 'title', searchString ?? '')
          .then((event) => event.map((e) => University.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }

  Future<List<Degree>?> getMastersDegree(String? searchString) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture('masters', 'title', searchString ?? '')
          .then((event) => event.map((e) => Degree.fromJson(e)).toList());
    } catch (e) {
      return null;
    }
  }

  Future<void> setBasicUserProfileData(UserBasicProfile userProfile) async {
    try {
      return await _databaseRepository.setData(
        'user_details',
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
          .searchDataFromFuture('indian_cities', 'name', searchQuery)
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
          .searchDataFromFuture('indian_states', 'name', searchQuery ?? '')
          .then((event) => event.map((e) => IndianState.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting states: $e');
      return [];
    }
  }

  Future<List<Language>> getLanguage(String? searchQuery) async {
    try {
      return await _databaseRepository
          .searchDataFromFuture('indian_languages', 'name', searchQuery ?? '')
          .then((event) => event.map((e) => Language.fromJson(e)).toList());
    } catch (e) {
      _logger.error('Error in getting languages: $e');
      return [];
    }
  }
}
