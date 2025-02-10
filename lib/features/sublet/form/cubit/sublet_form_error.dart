import 'package:nesters/data/repository/utils/app_exception.dart';

class SelectOneImageError extends AppException {
  @override
  String message;

  SelectOneImageError([this.message = "Please select at least one image"]);
}

class NoUploadImagePresentError extends AppException {
  @override
  String message;

  NoUploadImagePresentError([this.message = "No image to upload"]);
}

class UploadImageError extends AppException {
  @override
  String message;

  UploadImageError([this.message = "Error in uploading image"]);
}
