import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/media/media_repository.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/form/cubit/marketplace_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';

class MarketplacePhotoForm extends StatefulWidget {
  final TabController? controller;
  final MarketplaceModel? marketplaceModel;
  const MarketplacePhotoForm(
      {super.key, this.controller, this.marketplaceModel});

  @override
  State<MarketplacePhotoForm> createState() => _MarketplacePhotoFormState();
}

class _MarketplacePhotoFormState extends State<MarketplacePhotoForm>
    with AutomaticKeepAliveClientMixin {
  late final List<String> _uploadedImages =
      widget.marketplaceModel?.photos ?? [];
  final MediaRepository _mediaRepository = GetIt.I<MediaRepository>();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);
  bool isLoadingPhotos = false;
  @override
  bool get wantKeepAlive => true;

  void showImageErrorSnackbar() {
    context.showErrorSnackBar('Atleast one image is required to proceed');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<MarketplaceFormCubit, MarketplaceFormState>(
      listener: (context, state) {
        if (state.isValidating) {
          if (state.selectedImages.isEmpty && _uploadedImages.isEmpty) {
            showImageErrorSnackbar();
          } else {
            if (state.isPreFilled ?? false) {
              context.read<MarketplaceFormCubit>().updateMarketplace();
            } else {
              context.read<MarketplaceFormCubit>().createMarketplace();
            }
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

  void pickImages(List<File> imageList) async {
    if (imageList.length >= 5 - _uploadedImages.length) {
      showErrorSnackBar();
      return;
    }
    setState(() => isLoadingPhotos = true);
    final List<File> images = await _mediaRepository.getMultiImageFromGallery();
    setState(() => isLoadingPhotos = false);
    int remainingImages = 5 - (imageList.length + _uploadedImages.length);
    if (images.length >= remainingImages) {
      List<File> remaining = images.sublist(0, remainingImages);
      // ignore: use_build_context_synchronously
      context.read<MarketplaceFormCubit>().addPickedImages(remaining);
      showMaxImagesError();
    } else {
      // ignore: use_build_context_synchronously
      context.read<MarketplaceFormCubit>().addPickedImages(images);
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

  Widget _buildImages(MarketplaceFormState state, bool isLoadingPhotos) {
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
    } else if (state.selectedImages.isEmpty && _uploadedImages.isEmpty) {
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
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error_outline_rounded,
                          color: AppTheme.error,
                          size: 16,
                        );
                      },
                    ),
                  ),
                for (final image in state.selectedImages)
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
                            context
                                .read<MarketplaceFormCubit>()
                                .removePickedImage(image);
                            _index.value = _uploadedImages.length +
                                state.selectedImages.length;
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
                                state.selectedImages.length +
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

  Widget _buildSelectedImages(MarketplaceFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            pickImages(state.selectedImages);
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
          'Add up to 5 stunning photos to attract more buyers now!',
          textAlign: TextAlign.center,
          style: AppTheme.labelMediumLightVariant,
        )
      ],
    );
  }
}
