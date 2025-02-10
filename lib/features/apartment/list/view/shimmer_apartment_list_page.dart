import 'package:flutter/material.dart';
import 'package:nesters/features/apartment/components/shimmer_apartment_list_widget.dart';

class ShimmerApartmentPage extends StatelessWidget {
  const ShimmerApartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //create 7 shimmering cards
        for (int i = 0; i < 10; i++) const ShimmerApartmentModelWidget(),
      ],
    );
  }
}
