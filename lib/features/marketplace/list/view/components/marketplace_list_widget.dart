import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nesters/domain/models/marketplace/marketplace_model.dart';
import 'package:nesters/features/marketplace/list/view/components/marketplace_carousel.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/extensions/measure_units.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class MarketplaceModelWidget extends StatelessWidget {
  final MarketplaceModel marketplace;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Widget? action;
  final VoidCallback? onPressed;
  final Widget? bottom;
  final Future<void> Function(bool favouriteState)? onFavourite;
  const MarketplaceModelWidget({
    super.key,
    required this.marketplace,
    this.margin,
    this.padding,
    this.onPressed,
    this.action,
    this.onFavourite,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: margin ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(
            12,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyShades.shade300,
              blurRadius: 4,
              offset: const Offset(
                0,
                8,
              ),
            ),
          ],
          border: Border.all(
            color: AppTheme.greyShades.shade400,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    MarketplacePhotoCarousel(
                      photos: marketplace.photos ?? [],
                    ),
                    action ??
                        HeartIcon(
                          isFavourite: marketplace.isFavouriteByUser ?? false,
                          onPressed: onFavourite,
                        ),
                    _buildTitle(),
                    _buildDatePosted(),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketplaceInfo(),
                _buildMarketplacePrice(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DottedLine(
                width: double.infinity,
                color: AppTheme.greyShades.shade400,
                dashWidth: 7,
                spaceWidth: 2,
                height: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 10, right: 10),
              child: _buildLocation(),
            ),
            const SizedBox(height: 8),
            bottom ?? const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      bottom: -3,
      left: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 12, top: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.category,
              color: AppTheme.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${marketplace.category?.name.toTitleCase.toString()}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupPeriod() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          color: AppTheme.primary,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          marketplace.period?.periodFrom?.toShortUIDate(shortenYear: true) ??
              '',
          style: AppTheme.bodyMediumLightVariant,
        ),
        if (marketplace.period?.periodTill != null) ...[
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
            marketplace.period?.periodTill?.toShortUIDate(shortenYear: true) ??
                '',
            style: AppTheme.bodyMediumLightVariant,
          ),
          const SizedBox(width: 4),
        ]
      ],
    );
  }

  Widget _buildDatePosted() {
    return Positioned(
      top: 8,
      left: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
            child: Text(
              'Posted ${DateTime.fromMillisecondsSinceEpoch(marketplace.id).toUIDate().toTitleCase.toString()}',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.surface),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceInfo() {
    return Flexible(
      flex: 3,
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marketplace.name.capitalize.toString(),
              style: AppTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _buildPickupPeriod(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on_rounded,
          color: AppTheme.primary,
          size: 18,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            marketplace.address?.toTitleCase ?? '',
            style: AppTheme.bodyMediumLightVariant,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '${(marketplace.distanceFromUserInMeters ?? 0).roundMiles}mi away',
            style: AppTheme.labelMedium.copyWith(color: AppTheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplacePrice() {
    return Flexible(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '\$${marketplace.price}',
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
