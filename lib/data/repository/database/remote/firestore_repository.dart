import 'package:cloud_firestore/cloud_firestore.dart';

import 'error/firestore_error.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getData(String collectionPath,
      {int limit = 20}) async {
    try {
      final snapshot =
          await _firestore.collection(collectionPath).limit(limit).get();
      return snapshot.docs.first.data();
    } catch (e) {
      if (e is FirebaseException) {
        throw FirestoreError.fromCode(e.code);
      } else if (e is Exception) {
        throw FirestoreError.fromCode(FirestoreErrorCode.UNKNOWN.toString());
      }
    }
    return null;
  }

  Future<void> addData(String collectionPath, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      if (e is FirebaseException) {
        throw FirestoreError.fromCode(e.code);
      } else if (e is Exception) {
        throw FirestoreError.fromCode(FirestoreErrorCode.UNKNOWN.toString());
      }
    }
  }

  Future<void> setData(String path, Map<String, dynamic> data) async {
    try {
      await _firestore.doc(path).set(data);
    } catch (e) {
      if (e is FirebaseException) {
        throw FirestoreError.fromCode(e.code);
      } else if (e is Exception) {
        throw FirestoreError.fromCode(FirestoreErrorCode.UNKNOWN.toString());
      }
    }
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _firestore.doc(path).update(data);
    } catch (e) {
      if (e is FirebaseException) {
        throw FirestoreError.fromCode(e.code);
      } else if (e is Exception) {
        throw FirestoreError.fromCode(FirestoreErrorCode.UNKNOWN.toString());
      }
    }
  }

  Future<void> deleteData(String path) async {
    try {
      await _firestore.doc(path).delete();
    } catch (e) {
      if (e is FirebaseException) {
        throw FirestoreError.fromCode(e.code);
      } else if (e is Exception) {
        throw FirestoreError.fromCode(FirestoreErrorCode.UNKNOWN.toString());
      }
    }
  }

  Stream<List<Map<String, dynamic>?>> queryCollection(
      String collectionPath, String field, String value) {
    CollectionReference collectionRef = _firestore.collection(collectionPath);
    try {
      return collectionRef
          .where(
            field,
            isEqualTo: value,
            isGreaterThan: value,
            isGreaterThanOrEqualTo: value,
            isLessThan: value,
            isLessThanOrEqualTo: value,
          )
          .snapshots()
          .map(
        (snapshot) {
          List<Map<String, dynamic>?> streamValues = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>?)
              .toList();
          print(streamValues);
          return streamValues;
        },
      );
    } catch (e) {
      if (e is FirebaseException) {
        throw FirestoreError.fromCode(e.code);
      } else if (e is Exception) {
        throw FirestoreError.fromCode(FirestoreErrorCode.UNKNOWN.toString());
      }
    }
    return const Stream.empty();
  }
}
