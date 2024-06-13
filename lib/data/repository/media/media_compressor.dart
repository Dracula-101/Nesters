import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/utils/logger/logger.dart';

class MediaCompressor {
  Future<File?> compressFile(File file, {int quality = 50}) async {
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
        'Actual Size: $fileSize, Compressed file size: ${compressedFile.lengthSync()}');
    return compressedFile;
  }

  int _alterQuality(int fileSize) {
    if (fileSize < 1024 * 1024) {
      return 70;
    } else if (fileSize < 5 * 1024 * 1024) {
      return 55;
    } else {
      return 45;
    }
  }
}
