import 'package:flutter/material.dart';
import 'package:nesters/features/home/view/components/shimmer_user_quick_profile_widget.dart';
import 'package:nesters/utils/extensions/dimensions.dart';

class ShimmerHomePage extends StatelessWidget {
  const ShimmerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: GridView.builder(
        itemCount: 20,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).isTablet ? 2 : 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 130,
        ),
        itemBuilder: (context, index) {
          return const ShimmeringUserQuickProfileWidget();
        },
      ),
    );
  }
}
