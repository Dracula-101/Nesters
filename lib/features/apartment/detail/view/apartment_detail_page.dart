import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/components/amenities_details.dart';
import 'package:nesters/features/apartment/components/amenities_sheet.dart';
import 'package:nesters/features/apartment/detail/cubit/apartment_detail_cubit.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentDetailPage extends StatelessWidget {
  final ApartmentModel apartment;
  const ApartmentDetailPage({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApartmentDetailCubit(),
      child: Scaffold(
        bottomNavigationBar: ApartmentContactButton(
          apartmentId: apartment.id.toString(),
          ownerId: apartment.userId ?? '',
        ),
        body: Stack(
          children: [
            ApartmentDetailView(apartment: apartment),
            Positioned(
              top: 48,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.onSurface.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: AppTheme.onSurface,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApartmentContactButton extends StatelessWidget {
  final String apartmentId;
  final String ownerId;
  const ApartmentContactButton(
      {super.key, required this.apartmentId, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
      ),
      child: ElevatedButton(
        onPressed: () {
          ChatInfo? chatInfo =
              context.read<CentralChatBloc>().checkChatExists(ownerId);
          if (chatInfo != null) {
            GoRouter.of(context).go(
              "${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/${chatInfo.chatId}",
              extra: chatInfo.recipientUser.toUser(),
            );
          } else {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog.adaptive(
                title: Text('Contact Owner', style: AppTheme.titleLarge),
                content: Text(
                  'First, send a connection request to the owner. Would you like to proceed?',
                  style: AppTheme.bodyMediumLightVariant,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<RequestBloc>().add(
                            RequestEvent.sendRequest(ownerId),
                          );
                      Navigator.of(ctx).pop();
                      context.showSuccessSnackBar(
                          "Request sent successfully to the owner");
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            );
          }
        },
        child: Text(
          'Contact Owner',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.surface),
        ),
      ),
    );
  }
}

class ApartmentDetailView extends StatefulWidget {
  final ApartmentModel apartment;
  const ApartmentDetailView({super.key, required this.apartment});

  @override
  State<ApartmentDetailView> createState() => _ApartmentDetailViewState();
}

class _ApartmentDetailViewState extends State<ApartmentDetailView> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _hasScrolled = ValueNotifier(false);
  final double scrollMaxExtent = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _hasScrolled.value = _scrollController.offset > scrollMaxExtent;
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _scrollController.dispose();
    _hasScrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _hasScrolled,
        builder: (context, value, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: value ? AppTheme.surface : Colors.transparent,
              statusBarBrightness: Brightness.dark,
            ),
            child: child!,
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: HeroCarousel(images: widget.apartment.photos ?? []),
            ),
            _buildApartmentDetails(),
          ],
        ));
  }

  Widget _buildApartmentDetails() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList.list(
        children: [
          _buildRentTitle(),
          _buildSpacing(height: 4),
          _buildApartmentInfo(),
          _buildSpacing(height: 12),
          _buildAddress(),
          _buildSpacing(height: 12),
          _buildStartPeriod(),
          _buildSpacing(height: 12),
          _buildAmeneties(),
          _buildSpacing(height: 12),
          widget.apartment.apartmentDescription != ""
              ? _buildApartmentDescription()
              : const SizedBox(),
          _buildSpacing(height: 120),
        ],
      ),
    );
  }

  Widget _buildSpacing({double height = 12}) {
    return SizedBox(height: height);
  }

  Widget _buildRentTitle() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "\$ ",
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: '${widget.apartment.rent}',
            style: AppTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' / Month',
            style: AppTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentInfo() {
    return CustomCard(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Icon(
                  Icons.king_bed_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.apartment.apartmentSize?.beds} Bed${widget.apartment.apartmentSize?.beds == 1 ? '' : 's'}',
                  style: AppTheme.bodyMediumLightVariant,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 48,
            child: VerticalDivider(),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Icon(
                  Icons.bathtub_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.apartment.apartmentSize?.baths} Bath${widget.apartment.apartmentSize?.baths == 1 ? '' : 's'}',
                  style: AppTheme.bodyMediumLightVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartPeriod() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available From',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                widget.apartment.leasePeriod?.startDate
                        ?.toShortUIDate(shortenYear: true) ??
                    '',
                style: AppTheme.bodyMediumLightVariant,
              ),
            ],
          ),
          const SizedBox(height: 4)
        ],
      ),
    );
  }

  Widget _buildAddress() {
    return CustomCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              widget.apartment.location?.address.capitalizeEachWord ?? '',
              style: AppTheme.bodyMediumLightVariant,
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    ));
  }

  Widget _buildAmeneties() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          AmenitiesDetail(
            amenities: widget.apartment.amenitiesAvailable ?? Amenities(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildApartmentDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apartment Description',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.apartment.apartmentDescription.capitalize,
            style: AppTheme.bodyMediumLightVariant,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class HeroCarousel extends StatefulWidget {
  final List<String> images;
  const HeroCarousel({super.key, required this.images});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadImages();
    });
  }

  Future<void> preloadImages() async {
    await Future.wait(
      widget.images.map((photo) => precacheImage(NetworkImage(photo), context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              _currentPage.value = index;
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                          images: widget.images, initialIndex: index),
                    ),
                  );
                },
                child: Hero(
                  tag: 'hero_image_${widget.images[index]}',
                  child: CachedNetworkImage(
                    fadeInDuration: 0.sec,
                    imageUrl: widget.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.onSurface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _currentPage,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        ...List.generate(
                          widget.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.surface
                                  .withOpacity(index == value ? 1 : 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
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

class FullScreenImage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenImage(
      {super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late final PageController _pageController;
  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
    _currentPage.value = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.onSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppTheme.surface,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: 60,
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: _currentPage,
            builder: (context, value, child) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value + 1} / ${widget.images.length}',
                  style: AppTheme.bodySmall,
                ),
              );
            },
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        allowImplicitScrolling: true,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          _currentPage.value = index;
        },
        itemBuilder: (context, index) {
          // zoomable image
          return InteractiveViewer(
            maxScale: 5,
            child: Hero(
              tag: 'hero_image_${widget.images[index]}',
              child: CachedNetworkImage(
                fadeInDuration: 0.sec,
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
