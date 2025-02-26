import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesters/app/routes/app_routes.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/detail/cubit/marketplace_detail_cubit.dart';
import 'package:nesters/features/user/chat/bloc/central_chat/central_chat_bloc.dart';
import 'package:nesters/features/user/request/bloc/request_bloc.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceDetailPage extends StatelessWidget {
  final MarketplaceModel marketplace;
  const MarketplaceDetailPage({super.key, required this.marketplace});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketplaceDetailCubit(),
      child: Scaffold(
        bottomNavigationBar: MarketplaceContactButton(
          // Contact Button
          marketplaceId: marketplace.id.toString(),
          ownerId: marketplace.userId ?? '',
        ),
        body: Stack(
          children: [
            MarketplaceDetailView(marketplace: marketplace),
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

class MarketplaceContactButton extends StatelessWidget {
  final String marketplaceId;
  final String ownerId;
  const MarketplaceContactButton(
      {super.key, required this.marketplaceId, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state.requestSendState.exception != null) {
          context.showErrorSnackBar(state.requestSendState.exception!.message);
        } else if (state.requestSendState.isSuccess) {
          context.showSuccessSnackBar('Request sent successfully');
        }
      },
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
        ),
        child: ElevatedButton(
          onPressed: () {
            ChatInfo? chatInfo =
                context.read<CentralChatBloc>().checkChatExists(ownerId);
            if (chatInfo != null) {
              GoRouter.of(context).go(
                "${AppRouterService.homeScreen}/${AppRouterService.userChatHome}/${AppRouterService.userChatPage}/${chatInfo.chatId}",
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
                        context
                            .read<RequestBloc>()
                            .add(RequestEvent.sendRequest(ownerId));
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
      ),
    );
  }
}

class MarketplaceDetailView extends StatefulWidget {
  final MarketplaceModel marketplace;
  const MarketplaceDetailView({super.key, required this.marketplace});

  @override
  State<MarketplaceDetailView> createState() => _MarketplaceDetailViewState();
}

class _MarketplaceDetailViewState extends State<MarketplaceDetailView> {
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
              child: HeroCarousel(images: widget.marketplace.photos ?? []),
            ),
            _buildMarketplaceDetails(),
          ],
        ));
  }

  Widget _buildMarketplaceDetails() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList.list(
        children: [
          _buildPriceTitle(),
          _buildSpacing(height: 4),
          _buildName(),
          _buildSpacing(height: 12),
          _buildAddress(),
          _buildSpacing(height: 12),
          _buildLeasePeriod(),
          _buildSpacing(height: 12),
          _buildMarketplaceDescription(),
          _buildSpacing(height: 120),
        ],
      ),
    );
  }

  Widget _buildSpacing({double height = 12}) {
    return SizedBox(height: height);
  }

  Widget _buildPriceTitle() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "\$ ",
            style: AppTheme.bodyLarge,
          ),
          TextSpan(
            text: '${widget.marketplace.price}',
            style: AppTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w600,
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
            'Available Period',
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
                widget.marketplace.period?.periodFrom
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
                widget.marketplace.period?.periodTill
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
              widget.marketplace.address?.toTitleCase ?? '',
              style: AppTheme.bodyMediumLightVariant,
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    ));
  }

  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildName() {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.marketplace.name.toTitleCase,
                  style: AppTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.marketplace.category?.name ?? '',
                  style: AppTheme.bodyMediumLightVariant,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.marketplace.reference?.link != null) {
                _launchUrl(widget.marketplace.reference!.link!);
              }
            },
            child: Container(
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
                    'View on Store',
                    style: AppTheme.bodyMediumLightVariant.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.primary,
                    size: 14,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMarketplaceDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Description',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.marketplace.description.capitalize,
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
