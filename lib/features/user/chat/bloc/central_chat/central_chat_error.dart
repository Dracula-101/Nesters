import 'package:nesters/data/repository/utils/app_exception.dart';

class UserSocketError extends AppException {
  @override
  String message;

  UserSocketError(this.message);
}
