import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/features/apartment/form/view/apartment_details_form_page.dart';
import 'package:nesters/theme/theme.dart';

class AmenitiesBottomSheet extends StatefulWidget {
  final Amenities? amenities;
  final Function(Amenities amenities) onChanged;
  const AmenitiesBottomSheet(
      {super.key, this.amenities, required this.onChanged});

  @override
  State<AmenitiesBottomSheet> createState() => _AmenitiesBottomSheetState();
}

class _AmenitiesBottomSheetState extends State<AmenitiesBottomSheet> {
  Amenities? amenities;

  @override
  void initState() {
    super.initState();
    amenities = widget.amenities;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Amenities',
              style: AppTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  AmentityWidget(
                    title: 'Dryer',
                    value: widget.amenities?.hasDryer ?? false,
                    icon: Icons.dry,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasDryer: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Gym',
                    value: widget.amenities?.hasGym ?? false,
                    icon: Icons.fitness_center,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasGym: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Pool',
                    value: widget.amenities?.hasPool ?? false,
                    icon: Icons.pool,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasPool: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'AC',
                    value: widget.amenities?.hasAC ?? false,
                    icon: Icons.ac_unit,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasAC: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Gas',
                    value: widget.amenities?.hasGas ?? false,
                    icon: FontAwesomeIcons.fireBurner,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasGas: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Dishwasher',
                    value: widget.amenities?.hasDishwasher ?? false,
                    icon: Icons.dinner_dining,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasDishwasher: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Parking',
                    value: widget.amenities?.hasParking ?? false,
                    icon: Icons.local_parking,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasParking: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Balcony',
                    value: widget.amenities?.hasBalcony ?? false,
                    icon: Icons.balcony,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasBalcony: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Patio',
                    value: widget.amenities?.hasPatio ?? false,
                    icon: FontAwesomeIcons.piedPiperHat,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasPatio: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Heater',
                    value: widget.amenities?.hasHeater ?? false,
                    icon: FontAwesomeIcons.fire,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasHeater: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Semi Furnished',
                    value: widget.amenities?.hasSemiFurnished ?? false,
                    icon: Icons.weekend,
                    onChanged: (value) {
                      setState(() {
                        amenities =
                            amenities?.copyWith(hasSemiFurnished: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Furnished',
                    value: widget.amenities?.hasFurnished ?? false,
                    icon: Icons.weekend,
                    onChanged: (value) {
                      setState(() {
                        amenities = amenities?.copyWith(hasFurnished: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                  AmentityWidget(
                    title: 'Washing Machine',
                    value: widget.amenities?.hasWashingMachine ?? false,
                    icon: Icons.wash,
                    onChanged: (value) {
                      setState(() {
                        amenities =
                            amenities?.copyWith(hasWashingMachine: value);
                      });
                      widget.onChanged(amenities!);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
