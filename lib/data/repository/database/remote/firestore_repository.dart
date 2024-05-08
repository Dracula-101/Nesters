import 'package:cloud_firestore/cloud_firestore.dart';

import 'error/firestore_error.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getData(String collectionPath) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).get(const GetOptions(source: Source.server));
      Map<String, dynamic>? data = snapshot.docs
          .asMap()
          .map((key, value) => MapEntry(key.toString(), value.data()));
      return data;
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

}
