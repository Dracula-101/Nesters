import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:nesters/data/repository/user/status/user_status_repository.dart';
import 'package:nesters/domain/models/user/status/status.dart';
import 'package:nesters/domain/models/user/status/user_status.dart';

class FirebaseUserStatusRepository extends UserStatusRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _userStatusPath = 'user_status';

  @override
  Stream<UserStatus> getUserStatus(String userId) {
    try {
      //log user id
      print(userId);
      _database.ref('$_userStatusPath/$userId').onValue.listen((event) {
        // Handle event data here
        print("event.snapshot.value");
        print(event.snapshot.value);
      });
      return _database.ref('$_userStatusPath/$userId').onChildChanged.map(
          (event) => UserStatus.fromJson(
              event.snapshot.value as Map<String, dynamic>, userId));
    } catch (e) {
      log('Error getting user status: $e');
      return const Stream.empty();
    }
  }

  @override
  Future<void> updateUserStatus(Status userStatus, String userId) async {
    try {
      DatabaseReference reference = _database.ref('$_userStatusPath/$userId');
      Map<String, dynamic> status =
          UserStatus(status: userStatus).toJson(userId);
      await reference.update(status);
    } catch (e) {
      log('Error updating user status: $e');
      return Future.error(e);
    }
  }
}
