import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/domain/models/degree.dart';
import 'package:nesters/domain/models/university.dart';

class UserRepository {
  UserRepository({
    required AuthRepository authRepository,
    required LocalStorageRepository storageRepository,
    // required FirestoreRepository firestoreRepository,
  })  : _authRepository = authRepository,
        _storageRepository = storageRepository;

  final AuthRepository _authRepository;
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
}
