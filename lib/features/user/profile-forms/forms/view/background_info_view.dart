import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class BackgroundInfoPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const BackgroundInfoPage({super.key, required this.formKey});

  @override
  State<BackgroundInfoPage> createState() => _BackgroundInfoPageState();
}

class _BackgroundInfoPageState extends State<BackgroundInfoPage> {
  //undergrad college
  //workExperience
  // hobbies;
  final UserRepository userRepository = GetIt.I<UserRepository>();
  final TextEditingController undergradCollegeNameController =
      TextEditingController();
  final TextEditingController workExperienceController =
      TextEditingController();
  final TextEditingController flatmatesGenderController =
      TextEditingController();
  final TextEditingController roomTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              _buildRoomTypeField(),
              _buildSpacing(),
              _buildFlatemateGenderField(),
              _buildSpacing(),
              _buildUndergradCollegeField(),
              _buildSpacing(),
              _buildWorkExperienceField(),
            ],
          )),
    );
  }

  Widget _buildSpacing() {
    return const SizedBox(height: 20);
  }

  CustomBottomSheetDropdownField<FlatmateGenderType>
      _buildFlatemateGenderField() {
    return CustomBottomSheetDropdownField(
      controller: flatmatesGenderController,
      hintText: 'Flatemate\'s Gender Pref..',
      labelText: 'Flatemate\'s Gender Pref..',
      prefixIcon: const Icon(
        Icons.female,
      ),
      items: FlatmateGenderType.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a flatemate\'s gender preference.';
        }
        return null;
      },
    );
  }

  CustomBottomSheetDropdownField<UserRoomType> _buildRoomTypeField() {
    return CustomBottomSheetDropdownField(
      controller: roomTypeController,
      hintText: 'Room Preference',
      labelText: 'Room Preference',
      prefixIcon: const Icon(
        Icons.room_preferences,
      ),
      items: UserRoomType.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a room type';
        }
        return null;
      },
    );
  }

  Widget _buildUndergradCollegeField() {
    return CustomTextField(
      prefixIcon: const Icon(
        Icons.school,
      ),
      controller: undergradCollegeNameController,
      hintText: 'Undergrad College Name',
      labelText: 'Undergrad College Name',
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter your undergrad college name';
        }
        return null;
      },
      isCapitalized: true,
      maxLines: 1,
    );
  }

  Widget _buildWorkExperienceField() {
    return CustomTextField(
      prefixIcon: const Icon(
        Icons.work,
      ),
      controller: workExperienceController,
      keyboardType: TextInputType.number,
      hintText: '3',
      labelText: 'Work Experience (in yrs)',
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter your undergrad college name';
        }
        return null;
      },
      isCapitalized: true,
      maxLines: 1,
    );
  }
}
