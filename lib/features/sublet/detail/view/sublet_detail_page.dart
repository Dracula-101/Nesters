import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/domain/models/sublet/amenities.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/detail/cubit/sublet_detail_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletDetailPage extends StatelessWidget {
  final SubletModel sublet;
  const SubletDetailPage({super.key, required this.sublet});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubletDetailCubit(),
      child: Scaffold(
        body: Stack(
          children: [
            SubletDetailView(sublet: sublet),
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

class SubletDetailView extends StatefulWidget {
  final SubletModel sublet;
  const SubletDetailView({super.key, required this.sublet});

  @override
  State<SubletDetailView> createState() => _SubletDetailViewState();
}

class _SubletDetailViewState extends State<SubletDetailView> {
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
              child: HeroCarousel(images: widget.sublet.photos ?? []),
            ),
            _buildSubletDetails(),
          ],
        ));
  }

  Widget _buildSubletDetails() {
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
          _buildLeasePeriod(),
          _buildSpacing(height: 12),
          _buildAmeneties(),
          _buildSpacing(height: 12),
          _buildRoomDescription(),
          _buildSpacing(height: 12),
          _buildRoomateDescription(),
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
            style: AppTheme.headlineSmall,
          ),
          TextSpan(
            text: '${widget.sublet.rent}',
            style: AppTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' / month',
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
                  '${widget.sublet.apartmentSize?.beds} Bed${widget.sublet.apartmentSize?.beds == 1 ? '' : 's'}',
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
                  '${widget.sublet.apartmentSize?.baths} Bath${widget.sublet.apartmentSize?.baths == 1 ? '' : 's'}',
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
            flex: 3,
            child: Column(
              children: [
                Icon(
                  Icons.house_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.sublet.roomType!.toUI()} Room',
                  style: AppTheme.bodyMediumLightVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeasePeriod() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lease Period',
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
                widget.sublet.leasePeriod?.startDate
                        ?.toShortUIDate(shortenYear: true) ??
                    '',
                style: AppTheme.bodyMediumLightVariant,
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(),
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                widget.sublet.leasePeriod?.endDate
                        ?.toShortUIDate(shortenYear: true) ??
                    '',
                style: AppTheme.bodyMediumLightVariant,
              ),
              const SizedBox(width: 4),
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
              widget.sublet.location?.address ?? '',
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
          AmenitiesWidget(
            amenities: widget.sublet.amenitiesAvailable ?? Amenities(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRoomDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Description',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.sublet.roomDescription ?? '',
            style: AppTheme.bodyMediumLightVariant,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRoomateDescription() {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roommate Description',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.sublet.roommateDescription ?? '',
                  style: AppTheme.bodyMediumLightVariant,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Roommate Preference : ${widget.sublet.roommateGenderPref ?? ''}',
                  style: AppTheme.bodyMediumLightVariant.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          )
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

class AmenitiesWidget extends StatelessWidget {
  final Amenities amenities;
  const AmenitiesWidget({super.key, required this.amenities});

  bool get hasAmenities => amenities.hasAmenities();

  @override
  Widget build(BuildContext context) {
    bool ac = amenities.hasAC ?? false;
    bool dryer = amenities.hasDryer ?? false;
    bool washingMachine = amenities.hasWashingMachine ?? false;
    bool dishwasher = amenities.hasDishwasher ?? false;
    bool parking = amenities.hasParking ?? false;
    bool gym = amenities.hasGym ?? false;
    bool pool = amenities.hasPool ?? false;
    bool balcony = amenities.hasBalcony ?? false;
    bool patio = amenities.hasPatio ?? false;
    bool heater = amenities.hasHeater ?? false;
    bool furnished = amenities.hasFurnished ?? false;

    return hasAmenities
        ? Wrap(
            runAlignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ac)
                _buildAmenityTile(
                  icon: Icons.ac_unit_rounded,
                  title: 'AC',
                ),
              if (heater)
                _buildAmenityTile(
                  icon: Icons.fireplace_rounded,
                  title: 'Heater',
                ),
              if (dryer)
                _buildAmenityTile(
                  icon: Icons.dry_rounded,
                  title: 'Dryer',
                ),
              if (washingMachine)
                _buildAmenityTile(
                  icon: Icons.wash_rounded,
                  title: 'Washing Machine',
                ),
              if (dishwasher)
                _buildAmenityTile(
                  icon: Icons.dinner_dining_rounded,
                  title: 'Dishwasher',
                ),
              if (furnished)
                _buildAmenityTile(
                  icon: Icons.weekend_rounded,
                  title: 'Furnished',
                ),
              if (parking)
                _buildAmenityTile(
                  icon: Icons.local_parking_rounded,
                  title: 'Parking',
                ),
              if (gym)
                _buildAmenityTile(
                  icon: Icons.fitness_center_rounded,
                  title: 'Gym',
                ),
              if (pool)
                _buildAmenityTile(
                  icon: Icons.pool_rounded,
                  title: 'Pool',
                ),
              if (balcony)
                _buildAmenityTile(
                  icon: Icons.apartment_rounded,
                  title: 'Balcony',
                ),
              if (patio)
                _buildAmenityTile(
                  icon: Icons.deck_rounded,
                  title: 'Patio',
                ),
            ],
          )
        : Text(
            'No Amenities Available',
            style: AppTheme.bodyMediumLightVariant,
          );
  }

  Widget _buildAmenityTile({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primary.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppTheme.labelMedium,
          ),
          const SizedBox(width: 4),
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
