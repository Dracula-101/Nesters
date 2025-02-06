import 'dart:io';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nesters/data/repository/media/media_compressor.dart';

class MediaRepository {
  final ImagePicker _imagePicker = ImagePicker();
  final MediaCompressor compressor = MediaCompressor();

  Future<File?> getImageFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
    File file = File(image.path);
    return await compressor.compressFile(file);
  }

  //get image from camera
  Future<File?> getImageFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    }
    File file = File(image.path);
    return await compressor.compressFile(file);
  }

  Future<List<File>> getMultiImageFromGallery() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    List<File> files = [];
    for (XFile image in images) {
      File file = File(image.path);
      files.add(await compressor.compressFile(file));
    }
    return files;
  }

  Future<String> base64ClippedImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final clippedImage = await compressor.clipImageToCircle(bytes);
      return base64Encode(clippedImage);
    } else {
      throw Exception('Failed to load image');
    }
  }
}
