import 'package:nesters/data/repository/utils/app_exception.dart';

class UserNoPhotosUploadError extends AppException {
  @override
  String message;

  UserNoPhotosUploadError([
    this.message = 'Please upload at least one photo',
  ]);
}
