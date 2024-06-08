// ignore_for_file: constant_identifier_names

import 'package:nesters/domain/models/user/status/user_status.dart';

abstract class UserStatusRepository {
  Stream<UserStatus?> getUserStatus(String userId);
}