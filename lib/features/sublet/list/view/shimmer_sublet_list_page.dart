import 'package:flutter/material.dart';
import 'package:nesters/features/sublet/list/view/components/shimmer_sublet_list_widget.dart';

class ShimmerSubletPage extends StatelessWidget {
  const ShimmerSubletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //create 7 shimmering cards
        for (int i = 0; i < 2; i++) const ShimmerSubletModelWidget(),
      ],
    );
  }
}
