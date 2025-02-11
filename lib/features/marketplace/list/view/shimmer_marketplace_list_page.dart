import 'package:flutter/material.dart';
import 'package:nesters/features/marketplace/list/view/components/shimmer_marketplace_list_widget.dart';

class ShimmerMarketplacetPage extends StatelessWidget {
  const ShimmerMarketplacetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //create 7 shimmering cards
        for (int i = 0; i < 10; i++) const ShimmerMarketpalceModelWidget(),
      ],
    );
  }
}
