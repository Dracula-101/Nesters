import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringCard extends StatelessWidget {
  const ShimmeringCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Add some elevation for the shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            8), // Add some border radius for rounded corners
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300] as Color,
        highlightColor: Colors.grey[100] as Color,
        child: ListTile(
          leading: Container(
            width: 56, // Adjust the width as needed
            height: 56, // Adjust the height as needed
            color: Colors
                .white, // Shimmer effect will be applied to this container
          ),
          title: Container(
            width: MediaQuery.of(context).size.width *
                0.5, // Adjust the width as needed
            height: 20, // Adjust the height as needed
            color: Colors
                .white, // Shimmer effect will be applied to this container
          ),
          subtitle: Container(
            width: MediaQuery.of(context).size.width *
                0.7, // Adjust the width as needed
            height: 16, // Adjust the height as needed
            color: Colors
                .white, // Shimmer effect will be applied to this container
          ),
        ),
      ),
    );
  }
}
