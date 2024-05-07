import 'package:nesters/data/repository/cache/cache_repository.dart';
import 'package:nesters/data/repository/database/remote/firestore_repository.dart';
import 'package:nesters/domain/models/university.dart';

class UniversityRepository {
  UniversityRepository({
    required FirestoreRepository firestoreRepository,
  }) : _firestoreRepository = firestoreRepository;

  final FirestoreRepository _firestoreRepository;

  String universityCollection = "universities";

  Future<List<University?>> getUniversities() async {
    final universities =
        await _firestoreRepository.getData(universityCollection);
    if (universities != null) {
      return universities.entries
          .map((e) => University.fromJson(e.value))
          .toList();
    }
    return [];
  }
}
