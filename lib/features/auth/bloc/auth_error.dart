import 'package:nesters/data/repository/utils/app_exception.dart';

class UserNotAuthError implements AppException {
  @override
  String message;

  UserNotAuthError([this.message = "User not authenticated"]);
}
