import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/utils/logger/logger.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

class MediaCompressor {
  Future<File> compressFile(File file, {int quality = 35}) async {
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
      return 75;
    } else if (mb < 5) {
      return 65;
    } else if (mb < 10) {
      return 50;
    } else if (mb < 20) {
      return 35;
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

  Future<Uint8List> clipImageToCircle(Uint8List bytes) async {
    // Load the image from bytes
    final image = await _loadImageFromBytes(bytes);

    // Create a circular image from the loaded image
    final circularImage = await _createCircularImage(image);

    // Convert the circular image to bytes
    final byteData =
        await circularImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

// Load an image from bytes
  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

// Create a circular image using a `Canvas`
  Future<ui.Image> _createCircularImage(ui.Image image) async {
    final size = image.width < image.height ? image.width : image.height;

    // Create a circular mask
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0, 0), Offset(size.toDouble(), size.toDouble())));

    // Clip the canvas to a circle
    final paint = Paint()..isAntiAlias = true;
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size / 2, size / 2), radius: size / 2)));

    // Draw the image into the circular area
    canvas.drawImage(image, const Offset(0, 0), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    return img;
  }
}
