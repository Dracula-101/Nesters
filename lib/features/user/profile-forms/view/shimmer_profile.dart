import 'package:flutter/material.dart';
import 'package:nesters/constants/app_assets.dart';
import 'package:nesters/features/user/detail/view/components/shimmering_card.dart';
import 'package:nesters/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            const SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: 80,
              ), // Add vertical space here
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Divider(
                  thickness: 2,
                  color: AppColor.primaryBlueLightVariant,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const ShimmeringCard();
                },
                childCount: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 175,
      flexibleSpace: _buildProfileBanner(context),
    );
  }

  Stack _buildProfileBanner(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: <Widget>[
        // Add the background image
        Image.asset(
          AppRasterImages.userProfileBackgroundBanner,
          fit: BoxFit.cover,
          color: AppColor.appBlue,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Text(
              'User Profile',
              style: AppTheme.titleLargeLightVariant.copyWith(
                color: AppColor.appBlue,
              ),
            ),
          ),
        ),
        Positioned(
          height: 150,
          width: 150,
          bottom: -75,
          left: MediaQuery.of(context).size.width / 2 - 75,
          child: SizedBox(
            width: 150.0, // Adjust the width as needed
            height: 150.0, // Adjust the height as needed
            child: Shimmer.fromColors(
              baseColor: AppTheme.greyShades.shade300,
              highlightColor: AppTheme.greyShades.shade100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    75.0), // Half of width or height for a circular clip
                child: Container(
                  color: AppTheme.greyShades.shade200, // Shimmer effect will be applied to this container
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
