import 'package:nesters/data/repository/utils/app_exception.dart';

class NoNetworkError extends AppException {
  @override
  String message;

  NoNetworkError([
    this.message = "No network connection",
  ]);
}
