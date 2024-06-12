import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/sublet/list/view/components/sublet_carousel.dart';
import 'package:nesters/theme/theme.dart';

class SubletModelWidget extends StatelessWidget {
  final SubletModel sublet;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  const SubletModelWidget(
      {super.key, required this.sublet, this.margin, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  SubletPhotoCarousel(
                    photos: sublet.photos ?? [],
                  ),
                  _buildTitle(),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubletInfo(),
              _buildSubletRent(),
            ],
          ),
        ],
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
              Icons.bed_rounded,
              color: AppTheme.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${sublet.roomType?.toUI()} Room',
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubletInfo() {
    return Flexible(
      flex: 3,
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sublet.apartmentSize?.beds} Bed - ${sublet.apartmentSize?.baths} Bath Apartment',
              style: AppTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    sublet.location?.address ?? '',
                    style: AppTheme.bodyMediumLightVariant,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubletRent() {
    return Flexible(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.only(top: 12, right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '\$${sublet.rent}',
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
