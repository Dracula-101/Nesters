import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nesters/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMarketpalceModelWidget extends StatelessWidget {
  const ShimmerMarketpalceModelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    Shimmer.fromColors(
                      baseColor: AppTheme.greyShades.shade300,
                      highlightColor: AppTheme.greyShades.shade100,
                      child: Container(
                        color: AppTheme.greyShades.shade200,
                      ),
                    ),
                    Positioned(
                      top: -15,
                      right: -15,
                      child: Lottie.asset(
                        'assets/lottie/like_lottie.json',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
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
                _buildSubletInfo(),
                _buildSubletRent(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: _buildLocation(),
            ),
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
            Shimmer.fromColors(
              baseColor: AppTheme.greyShades.shade100,
              highlightColor: AppTheme.greyShades.shade300,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.greyShades.shade200,
                ),
                width: 100,
                height: 20,
              ),
            )
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
        Shimmer.fromColors(
          baseColor: AppTheme.greyShades.shade100,
          highlightColor: AppTheme.greyShades.shade300,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.greyShades.shade200,
            ),
            width: 275,
            height: 25,
          ),
        )
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
            child: Shimmer.fromColors(
              baseColor: AppTheme.greyShades.shade300,
              highlightColor: Colors.grey[600]!,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.greyShades.shade200,
                ),
                width: 125,
                height: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubletInfo() {
    return Flexible(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: AppTheme.greyShades.shade100,
              highlightColor: AppTheme.greyShades.shade300,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.greyShades.shade200,
                ),
                width: 225,
                height: 20,
              ),
            ),
            const SizedBox(height: 6),
            _buildLeasePeriod(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeasePeriod() {
    return Shimmer.fromColors(
      baseColor: AppTheme.greyShades.shade100,
      highlightColor: AppTheme.greyShades.shade300,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.greyShades.shade200,
        ),
        width: 275,
        height: 25,
      ),
    );
  }

  Widget _buildSubletRent() {
    return Flexible(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.indigo,
          highlightColor: Colors.indigoAccent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.greyShades.shade200,
            ),
            width: 50,
            height: 25,
          ),
        ),
      ),
    );
  }
}
