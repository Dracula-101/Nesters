import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/domain/models/degree.dart';
import 'package:nesters/domain/models/university.dart';
import 'package:nesters/domain/models/user_basic_profile.dart';

class UserRepository {
  UserRepository({
    required AuthRepository authRepository,
    required DatabaseRepository databaseRepository,
    required LocalStorageRepository storageRepository,
    // required FirestoreRepository firestoreRepository,
  })  : _authRepository = authRepository,
        _databaseRepository = databaseRepository,
        _storageRepository = storageRepository;

  final AuthRepository _authRepository;
  final DatabaseRepository _databaseRepository;
  final LocalStorageRepository _storageRepository;

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
          key: 'user_id',
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
}
