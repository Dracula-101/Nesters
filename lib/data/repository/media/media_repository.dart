import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:nesters/data/repository/media/media_compressor.dart';

class MediaRepository {
  final ImagePicker _imagePicker = ImagePicker();
  final MediaCompressor _mediaCompressor = MediaCompressor();

  Future<File?> getImageFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
    File file = File(image.path);
    return await _mediaCompressor.compressFile(file);
  }

  //get image from camera
  Future<File?> getImageFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    }
    File file = File(image.path);
    return await _mediaCompressor.compressFile(file);
  }
}
