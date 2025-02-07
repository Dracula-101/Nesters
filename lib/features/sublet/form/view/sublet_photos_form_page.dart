import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/form/cubit/sublet_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class SubletPhotoForm extends StatefulWidget {
  final TabController? controller;
  final SubletModel? sublet;
  const SubletPhotoForm({super.key, this.controller, this.sublet});

  @override
  State<SubletPhotoForm> createState() => _SubletPhotoFormState();
}

class _SubletPhotoFormState extends State<SubletPhotoForm>
    with AutomaticKeepAliveClientMixin {
  final List<String> _uploadedImages = [];
  final MediaRepository _mediaRepository = GetIt.I<MediaRepository>();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);
  bool isLoadingPhotos = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.sublet != null) {
      _uploadedImages.addAll(widget.sublet!.photos ?? []);
    }
  }

  void showImageErrorSnackbar() {
    context.showErrorSnackBar('Atleast one image is required to proceed');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<SubletFormCubit, SubletFormState>(
      listener: (context, state) {
        if (state.isValidating) {
          if (state.pickedImages.isEmpty && state.isPreFilled == false) {
            showImageErrorSnackbar();
          } else if (state.isPreFilled ?? false) {
            context.read<SubletFormCubit>().updateSublet();
          } else {
            context.read<SubletFormCubit>().createSublet();
          }
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImages(state, isLoadingPhotos),
              _buildSpacing(),
              _buildSelectedImages(state),
            ],
          ),
        );
      },
    );
  }

  void pickImages(List<File> pickedImages) async {
    if ((pickedImages.length + _uploadedImages.length) >= 5) {
      showErrorSnackBar();
      return;
    }
    setState(() => isLoadingPhotos = true);
    final List<File> images = await _mediaRepository.getMultiImageFromGallery();
    setState(() => isLoadingPhotos = false);
    int remainingImages = 5 - (pickedImages.length + _uploadedImages.length);
    if (images.length > remainingImages) {
      List<File> imagesToPick = images.sublist(0, remainingImages);
      showMaxImagesError();
      // ignore: use_build_context_synchronously
      context.read<SubletFormCubit>().addImages(imagesToPick);
    } else {
      // ignore: use_build_context_synchronously
      context.read<SubletFormCubit>().addImages(images);
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

  Widget _buildImages(SubletFormState state, bool isLoadingPhotos) {
    if (isLoadingPhotos) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.greyShades.shade400,
          ),
        ),
        height: 200,
        width: double.infinity,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Processsing photos...'),
          ],
        ),
      );
    } else if (state.pickedImages.isEmpty &&
        (widget.sublet?.photos?.isEmpty ?? true)) {
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
                for (final image in _uploadedImages)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                for (final image in state.pickedImages)
                  Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            context.read<SubletFormCubit>().removeImage(image);
                            _index.value = _uploadedImages.length +
                                state.pickedImages.length;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
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
                        for (int i = 0;
                            i <
                                state.pickedImages.length +
                                    _uploadedImages.length;
                            i++)
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

  Widget _buildSelectedImages(SubletFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            pickImages(state.pickedImages);
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
