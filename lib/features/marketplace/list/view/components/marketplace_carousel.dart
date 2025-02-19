import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';

class MarketplacePhotoCarousel extends StatefulWidget {
  final List<String> photos;
  const MarketplacePhotoCarousel({super.key, required this.photos});

  @override
  State<MarketplacePhotoCarousel> createState() =>
      _MarketplacePhotoCarouselState();
}

class _MarketplacePhotoCarouselState extends State<MarketplacePhotoCarousel> {
  final PageController _pageController = PageController();
  double coverHeight = 40;
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadImages();
    });
  }

  Future<void> preloadImages() async {
    try {
      await Future.wait(
        widget.photos.map((photo) => precacheImage(
            CachedNetworkImageProvider(
              photo,
              cacheKey: "$photo-marketplace-photo",
            ),
            context)),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (index) {
            _currentPage.value = index;
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.photos[index],
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error),
              ),
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              cacheKey: "${widget.photos[index]}-marketplace-photo",
              alignment: Alignment.center,
              memCacheWidth: 800,
              filterQuality: FilterQuality.high,
            );
          },
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: coverHeight,
            width: MediaQuery.of(context).size.width - 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.onSurface.withOpacity(0.5),
                  AppTheme.onSurface,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: (coverHeight / 2.8),
          right: (coverHeight / 2.5),
          child: Row(
            children: [
              if (widget.photos.length > 1)
                ...List.generate(
                  widget.photos.length,
                  (index) => ValueListenableBuilder(
                    valueListenable: _currentPage,
                    builder: (context, value, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: value == index
                              ? AppTheme.surface
                              : AppTheme.surface.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
