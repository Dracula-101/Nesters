import 'package:flutter/material.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/theme/theme.dart';

class AmenitiesDetail extends StatelessWidget {
  final Amenities amenities;
  const AmenitiesDetail({super.key, required this.amenities});

  bool get hasAmenities => amenities.hasAmenities();

  @override
  Widget build(BuildContext context) {
    bool ac = amenities.hasAC ?? false;
    bool dryer = amenities.hasDryer ?? false;
    bool washingMachine = amenities.hasWashingMachine ?? false;
    bool dishwasher = amenities.hasDishwasher ?? false;
    bool parking = amenities.hasParking ?? false;
    bool gym = amenities.hasGym ?? false;
    bool pool = amenities.hasPool ?? false;
    bool balcony = amenities.hasBalcony ?? false;
    bool patio = amenities.hasPatio ?? false;
    bool heater = amenities.hasHeater ?? false;
    bool furnished = amenities.hasFurnished ?? false;

    return hasAmenities
        ? Wrap(
            runAlignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ac)
                _buildAmenityTile(
                  icon: Icons.ac_unit_rounded,
                  title: 'AC',
                ),
              if (heater)
                _buildAmenityTile(
                  icon: Icons.fireplace_rounded,
                  title: 'Heater',
                ),
              if (dryer)
                _buildAmenityTile(
                  icon: Icons.dry_rounded,
                  title: 'Dryer',
                ),
              if (washingMachine)
                _buildAmenityTile(
                  icon: Icons.wash_rounded,
                  title: 'Washing Machine',
                ),
              if (dishwasher)
                _buildAmenityTile(
                  icon: Icons.dinner_dining_rounded,
                  title: 'Dishwasher',
                ),
              if (furnished)
                _buildAmenityTile(
                  icon: Icons.weekend_rounded,
                  title: 'Furnished',
                ),
              if (parking)
                _buildAmenityTile(
                  icon: Icons.local_parking_rounded,
                  title: 'Parking',
                ),
              if (gym)
                _buildAmenityTile(
                  icon: Icons.fitness_center_rounded,
                  title: 'Gym',
                ),
              if (pool)
                _buildAmenityTile(
                  icon: Icons.pool_rounded,
                  title: 'Pool',
                ),
              if (balcony)
                _buildAmenityTile(
                  icon: Icons.apartment_rounded,
                  title: 'Balcony',
                ),
              if (patio)
                _buildAmenityTile(
                  icon: Icons.deck_rounded,
                  title: 'Patio',
                ),
            ],
          )
        : Text(
            'No Amenities Available',
            style: AppTheme.bodyMediumLightVariant,
          );
  }

  Widget _buildAmenityTile({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primary.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppTheme.labelMedium,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
