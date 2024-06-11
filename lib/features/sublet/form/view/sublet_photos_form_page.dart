import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class SubletPhotoForm extends StatefulWidget {
  final TabController? controller;
  const SubletPhotoForm({super.key, this.controller});

  @override
  State<SubletPhotoForm> createState() => _SubletPhotoFormState();
}

class _SubletPhotoFormState extends State<SubletPhotoForm> {
  final List<XFile> _imageList = [];
  final ImagePicker _picker = ImagePicker();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImages(),
          _buildSpacing(),
          _buildSelectedImages(),
        ],
      ),
    );
  }

  void pickImages() async {
    if (_imageList.length >= 5) {
      showErrorSnackBar();
      return;
    }
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _imageList.addAll(images.length > 5 - _imageList.length
          ? images.sublist(0, 5 - _imageList.length)
          : images);
      setState(() {});
      if (images.length > 5) {
        showMaxImagesError();
      }
    }
  }

  void showMaxImagesError() {
    context.showErrorSnackBar(
      'Only first 5 images were added. You can only add up to 5 images.',
    );
  }

  void showErrorSnackBar() {
    context.showErrorSnackBar(
      'You can only add up to 5 images',
    );
  }

  Widget _buildImages() {
    if (_imageList.isEmpty) {
      return const SizedBox();
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              onPageChanged: (index) {
                _index.value = index;
              },
              children: [
                for (final image in _imageList)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.greyShades.shade800.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _index,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        for (int i = 0; i < _imageList.length; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == value
                                  ? AppTheme.surface
                                  : AppTheme.greyShades.shade600,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSpacing() {
    return const SizedBox(height: 16);
  }

  Widget _buildSelectedImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            pickImages();
          },
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: [6, 3],
            radius: const Radius.circular(12),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: AppTheme.greyShades.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Photos',
                    style: TextStyle(
                      color: AppTheme.greyShades.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 5 stunning photos to attract more tenants now!',
          textAlign: TextAlign.center,
          style: AppTheme.labelMediumLightVariant,
        )
      ],
    );
  }
}
