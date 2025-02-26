import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nesters/domain/models/apartment/apartment_model.dart';
import 'package:nesters/features/apartment/list/view/components/apartment_carousel.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class ApartmentModelWidget extends StatelessWidget {
  final ApartmentModel apartment;
  final EdgeInsets? margin;
  final Widget? action;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  final Widget? bottom;
  final Future<void> Function(bool favouriteState)? actionOnFavourite;
  const ApartmentModelWidget({
    super.key,
    required this.apartment,
    this.margin,
    this.padding,
    this.onPressed,
    this.action,
    this.actionOnFavourite,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyShades.shade300,
              blurRadius: 4,
              offset: const Offset(0, 8),
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
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    ApartmentPhotoCarousel(
                      photos: apartment.photos ?? [],
                    ),
                    action ??
                        HeartIcon(
                          isFavourite: apartment.isFavouriteByUser ?? false,
                          onPressed: actionOnFavourite,
                        ),
                    _buildDatePosted(),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildApartmentInfo(),
                _buildApartmentRent(),
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

  Widget _buildStartPeriod() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          color: AppTheme.primary,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          ('Available From: ${apartment.leasePeriod?.startDate!.toShortUIDate(shortenYear: true)}'),
          style: AppTheme.bodyMediumLightVariant,
        ),
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
              'Posted ${DateTime.fromMillisecondsSinceEpoch(apartment.id).toUIDate().toTitleCase}',
              style: AppTheme.labelMedium.copyWith(color: AppTheme.surface),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApartmentInfo() {
    return Flexible(
      flex: 3,
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${apartment.apartmentSize?.beds} Bed - ${apartment.apartmentSize?.baths} Bath Apartment',
              style: AppTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            _buildStartPeriod(),
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
            apartment.address.toTitleCase ?? '',
            style: AppTheme.bodyMediumLightVariant,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  Widget _buildApartmentRent() {
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
          '\$${apartment.rent}',
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
