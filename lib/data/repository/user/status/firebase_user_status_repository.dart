import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';

class FirebaseUserStatusRepository extends UserStatusRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _userStatusPath = 'user_status';

  @override
  Stream<UserStatus?> getUserStatus(String userId) {
    try {
      return _database.ref('$_userStatusPath/$userId').onValue.map((event) {
        return event.snapshot.value != null
            ? UserStatus.fromJson(event.snapshot.value as Map, userId)
            : null;
      });
    } catch (e) {
      log('Error getting user status: $e');
      return const Stream.empty();
    }
  }
}
