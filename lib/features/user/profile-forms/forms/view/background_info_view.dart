import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class BackgroundInfoPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final CurrentFormState currentFormState;
  const BackgroundInfoPage(
      {super.key, required this.formKey, required this.currentFormState});

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
  void initState() {
    super.initState();
    if (widget.currentFormState.userFormProfile.undergradCollegeName != null) {
      undergradCollegeNameController.text =
          widget.currentFormState.userFormProfile.undergradCollegeName!;
    }
    if (widget.currentFormState.userFormProfile.workExperience != null) {
      workExperienceController.text =
          widget.currentFormState.userFormProfile.workExperience.toString();
    }
    if (widget.currentFormState.userFormProfile.flatmateGenderPrefs != null) {
      flatmatesGenderController.text =
          widget.currentFormState.userFormProfile.flatmateGenderPrefs!;
    }
    if (widget.currentFormState.userFormProfile.roomType != null) {
      roomTypeController.text =
          widget.currentFormState.userFormProfile.roomType!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormCubit, CurrentFormState>(
      listener: (context, state) {
        if (state.validationState.isLoading) {
          context.read<FormCubit>().addData(
                underGradCollegeName: undergradCollegeNameController.text,
                workExp: int.tryParse(workExperienceController.text),
                flatmateGenderPrefs: flatmatesGenderController.text,
                roomType: UserRoomType.fromString(roomTypeController.text),
              );
          if (state.currentPage == 2) {
            context.read<FormCubit>().submitForm();
          }
        }
      },
      child: Padding(
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
          ),
        ),
      ),
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
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(flatmateGenderPrefs: value);
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
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(workExp: value);
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
