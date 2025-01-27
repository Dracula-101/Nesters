import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/utils/logger/logger.dart';

class MediaCompressor {
  Future<File> compressFile(File file, {int quality = 50}) async {
    int fileSize = file.lengthSync();
    quality = _alterQuality(fileSize);
    final imageBytes = file.readAsBytesSync();
    Uint8List result = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: quality,
    );
    File compressedFile = File(file.path);
    await compressedFile.writeAsBytes(result);
    GetIt.I<AppLogger>().debug(
        'Actual Size: ${bytesToReadable(fileSize)}, Compressed file size: ${bytesToReadable(compressedFile.lengthSync())}');
    return compressedFile;
  }

  int _alterQuality(int fileSize) {
    double mb = fileSize / (1024 * 1024);
    if (mb < 1) {
      return 90;
    } else if (mb < 5) {
      return 70;
    } else if (mb < 10) {
      return 60;
    } else if (mb < 20) {
      return 40;
    } else {
      return 30;
    }
  }

  String bytesToReadable(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
