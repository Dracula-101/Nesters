import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesters/domain/models/apartment/amenities.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';
import 'package:nesters/features/apartment/components/amenities_sheet.dart';
import 'package:nesters/features/sublet/form/cubit/sublet_form_cubit.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class SubletBackgroundInfo extends StatefulWidget {
  final TabController? controller;
  final SubletModel? sublet;
  const SubletBackgroundInfo({super.key, this.controller, this.sublet});

  @override
  State<SubletBackgroundInfo> createState() => SubletBackgroundInfoState();
}

class SubletBackgroundInfoState extends State<SubletBackgroundInfo>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _roomDescriptionController =
      TextEditingController();
  final TextEditingController _roommateDescriptionController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Amenities amenities = Amenities();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.sublet != null) {
      _roomDescriptionController.text = widget.sublet!.roomDescription ?? '';
      _roommateDescriptionController.text =
          widget.sublet!.roommateDescription ?? '';
      amenities = widget.sublet!.amenitiesAvailable ?? Amenities();
    }
    widget.controller?.addListener(() => addData());
  }

  bool validatePage() {
    bool allFieldsValid = _formKey.currentState?.validate() ?? false;
    return allFieldsValid;
  }

  void addData() {
    context.read<SubletFormCubit>().addSecondPageData(
          roomDescription: _roomDescriptionController.text.trim(),
          roommateDescription: _roommateDescriptionController.text.trim(),
          amenities: amenities,
        );
  }

  @override
  void dispose() {
    _roomDescriptionController.dispose();
    _roommateDescriptionController.dispose();
    widget.controller?.removeListener(() => addData());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SubletFormCubit, SubletFormState>(
      listener: (context, state) {
        if (state.isValidating) {
          if (validatePage() || state.hasThirdPageAccess) {
            context.read<SubletFormCubit>().showPageValid(2);
            widget.controller?.animateTo(2);
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
      hintText:
          'Ex. This spacious room is bright and cheerful with natural light 🌞 streaming through a large window 🪟. It features a luxurious king-size bed 🛏️, stylish furniture 🪑 with ample storage, cozy reading corner 🌿, and modern decor accented with tasteful artwork 🖼️.',
      alignLabelWithHint: true,
      maxLines: 5,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a room description';
        }
        return null;
      },
    );
  }

  Widget _buildAmenities() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return AmenitiesBottomSheet(
              amenities: amenities,
              onChanged: (selectedAmenities) {
                setState(() {
                  amenities = selectedAmenities;
                });
              },
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.greyShades.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: BlocBuilder<SubletFormCubit, SubletFormState>(
          builder: (context, state) {
            return Row(
              children: [
                Icon(
                  (state.isPreFilled == true)
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                ),
                const SizedBox(width: 8),
                Text(
                  "Select${state.isPreFilled == true ? "ed" : ""} Amenties",
                  style: AppTheme.bodyLarge,
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoommateDescription() {
    return CustomTextField(
      controller: _roommateDescriptionController,
      labelText: 'Roommate Description',
      hintText:
          'Eg: We are currently three male Master\'s students at NYU, all studying Computer Science. Friendly and focused, we maintain a balanced study and social environment.',
      alignLabelWithHint: true,
      maxLines: 3,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a roommate description';
        }
        return null;
      },
    );
  }
}
