import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/domain/models/degree.dart';
import 'package:nesters/domain/models/university.dart';

class UserRepository {
  UserRepository({
    required AuthRepository authRepository,
    required LocalStorageRepository storageRepository,
    required FirestoreRepository firestoreRepository,
  })  : _authRepository = authRepository,
        _storageRepository = storageRepository,
        _firestoreRepository = firestoreRepository;

  final AuthRepository _authRepository;
  final LocalStorageRepository _storageRepository;
  final FirestoreRepository _firestoreRepository;

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
    final universities =
        await _firestoreRepository.getData(universityCollection);
    if (universities != null) {
      return universities.entries
          .map((e) => University.fromJson(e.value))
          .toList();
    }
    return [];
  }

  Future<List<Degree?>> getAllDegrees() async {
    final degrees = await _firestoreRepository.getData(masterDegreeCollection);
    if (degrees != null) {
      return degrees.entries.map((e) => Degree.fromJson(e.value)).toList();
    }
    return [];
  }
}
