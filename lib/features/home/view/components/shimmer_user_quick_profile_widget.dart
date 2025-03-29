import 'package:flutter/material.dart';
import 'package:nesters/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringUserQuickProfileWidget extends StatelessWidget {
  const ShimmeringUserQuickProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.greyShades.shade300,
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Shimmer.fromColors(
            baseColor: AppTheme.greyShades.shade300,
            highlightColor: AppTheme.greyShades.shade100,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.greyShades.shade200,
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppTheme.greyShades.shade300,
                  highlightColor: AppTheme.greyShades.shade100,
                  child: Container(
                    width: double.infinity,
                    height: 20,
                    color: AppTheme.greyShades.shade200,
                  ),
                ),
                const SizedBox(height: 2),
                Shimmer.fromColors(
                  baseColor: AppTheme.greyShades.shade300,
                  highlightColor: AppTheme.greyShades.shade100,
                  child: Container(
                    width: 60,
                    height: 20,
                    color: AppTheme.greyShades.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: AppTheme.greyShades.shade200,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: AppTheme.greyShades.shade200,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
