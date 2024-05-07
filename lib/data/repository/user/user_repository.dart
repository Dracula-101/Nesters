import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/database/local/local_storage_repository.dart';

class UserRepository {
  UserRepository({
    required AuthRepository authRepository,
    required LocalStorageRepository storageRepository,
  })  : _authRepository = authRepository,
        _storageRepository = storageRepository;

  final AuthRepository _authRepository;
  final LocalStorageRepository _storageRepository;

  Future<void> setOnBoardingComplete() async {
    await _storageRepository.saveBool(
        LocalStorageKeys.userOnboardingComplete, true);
  }

  Future<bool> checkUserOnboardingStatus() async {
    return await _storageRepository
            .getBool(LocalStorageKeys.userOnboardingComplete) ??
        false;
  }
}
