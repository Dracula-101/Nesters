import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/features/sublet/form/cubit/sublet_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletBackgroundInfo extends StatefulWidget {
  final TabController? controller;
  const SubletBackgroundInfo({super.key, this.controller});

  @override
  State<SubletBackgroundInfo> createState() => SubletBackgroundInfoState();
}

class SubletBackgroundInfoState extends State<SubletBackgroundInfo>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _roomDescriptionController =
      TextEditingController();
  final TextEditingController _roommateDescriptionController =
      TextEditingController();

  bool hasDryer = false,
      hasWashingMachine = false,
      hasDishwasher = false,
      hasParking = false,
      hasGym = false,
      hasPool = false,
      hasBalcony = false,
      hasPatio = false,
      hasAC = false,
      hasHeater = false,
      hasFurnished = false;
  List<String>? extraAmenities;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SubletFormCubit, SubletFormState>(
      listener: (context, state) {
        // NOTE: No need for validation here
        context.read<SubletFormCubit>().showPageValid(2);
        widget.controller?.animateTo(2);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomDescription(),
              _buildSpacing(),
              _buildAmenities(),
              _buildSpacing(height: 32),
              _buildSubSectionTitle('Current Tenants Info'),
              _buildSpacing(),
              _buildRoommateDescription(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(),
        Container(
          decoration: BoxDecoration(color: AppTheme.surface),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
          ),
        )
      ],
    );
  }

  Widget _buildSpacing({double height = 16}) => SizedBox(height: height);

  Widget _buildRoomDescription() {
    return CustomTextField(
      controller: _roomDescriptionController,
      labelText: 'Room Description',
      hintText: 'Describe the room',
      alignLabelWithHint: true,
      maxLines: 4,
    );
  }

  Widget _buildAmenities() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: ((context) => _buildAmenitiesBottomSheet()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add,
            ),
            const SizedBox(width: 8),
            Text(
              "Select Amenties",
              style: AppTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoommateDescription() {
    return CustomTextField(
      controller: _roommateDescriptionController,
      labelText: 'Roommate Description',
      hintText: 'Eg: We are a group of 3 students looking for a 4th roommate.',
      alignLabelWithHint: true,
      maxLines: 2,
    );
  }

  Widget _buildAmenitiesBottomSheet() {
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
                    value: hasDryer,
                    icon: Icons.dry,
                    onChanged: (value) {
                      setState(() {
                        hasDryer = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Gym',
                    value: hasGym,
                    icon: Icons.fitness_center,
                    onChanged: (value) {
                      setState(() {
                        hasGym = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Pool',
                    value: hasPool,
                    icon: Icons.pool,
                    onChanged: (value) {
                      setState(() {
                        hasPool = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'AC',
                    value: hasAC,
                    icon: Icons.ac_unit,
                    onChanged: (value) {
                      setState(() {
                        hasAC = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Dishwasher',
                    value: hasDishwasher,
                    icon: Icons.dinner_dining,
                    onChanged: (value) {
                      setState(() {
                        hasDishwasher = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Parking',
                    value: hasParking,
                    icon: Icons.local_parking,
                    onChanged: (value) {
                      setState(() {
                        hasParking = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Balcony',
                    value: hasBalcony,
                    icon: Icons.balcony,
                    onChanged: (value) {
                      setState(() {
                        hasBalcony = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Patio',
                    value: hasPatio,
                    icon: FontAwesomeIcons.piedPiperHat,
                    onChanged: (value) {
                      setState(() {
                        hasPatio = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Heater',
                    value: hasHeater,
                    icon: FontAwesomeIcons.fire,
                    onChanged: (value) {
                      setState(() {
                        hasHeater = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Furnished',
                    value: hasFurnished,
                    icon: Icons.weekend,
                    onChanged: (value) {
                      setState(() {
                        hasFurnished = value;
                      });
                    },
                  ),
                  AmentityWidget(
                    title: 'Washing Machine',
                    value: hasWashingMachine,
                    icon: Icons.wash,
                    onChanged: (value) {
                      setState(() {
                        hasWashingMachine = value;
                      });
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

class AmentityWidget extends StatefulWidget {
  final bool value;
  final String title;
  final IconData icon;
  final Function(bool) onChanged;
  final double? iconsSize;
  const AmentityWidget(
      {super.key,
      required this.value,
      required this.title,
      required this.icon,
      required this.onChanged,
      this.iconsSize});

  @override
  State<AmentityWidget> createState() => _AmentityWidgetState();
}

class _AmentityWidgetState extends State<AmentityWidget> {
  bool currentValue = false;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentValue = !currentValue;
          widget.onChanged(currentValue);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: currentValue
              ? AppTheme.primaryShades.shade100
              : AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                currentValue ? AppTheme.primary : AppTheme.greyShades.shade300,
            width: currentValue ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: currentValue
                  ? AppTheme.primary
                  : AppTheme.primaryShades.shade300,
              size: widget.iconsSize ?? 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: AppTheme.bodyMedium.copyWith(
                color: currentValue
                    ? AppTheme.primary
                    : AppTheme.primaryShades.shade300,
              ),
            ),
            const SizedBox(width: 8),
            if (currentValue)
              Icon(
                Icons.check,
                color: AppTheme.primary,
              )
            else
              Icon(
                Icons.close,
                color: AppTheme.primaryShades.shade300,
              ),
          ],
        ),
      ),
    );
  }
}
