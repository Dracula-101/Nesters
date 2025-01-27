import 'dart:io';

import 'dart:convert';
import 'package:http/http.dart' as http;
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

  Future<List<File>> getMultiImageFromGallery() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    List<File> files = [];
    for (XFile image in images) {
      File file = File(image.path);
      files.add(await _mediaCompressor.compressFile(file));
    }
    return files;
  }

  Future<String> base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }
}
