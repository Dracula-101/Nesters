import 'package:flutter/material.dart';
import 'package:nesters/features/home/view/components/shimmer_user_quick_profile_widget.dart';

class ShimmerHomePage extends StatelessWidget {
  const ShimmerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //create 7 shimmering cards
          for (int i = 0; i < 15; i++) const ShimmeringUserQuickProfileWidget(),
        ],
      ),
    );
  }
}
