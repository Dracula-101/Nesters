import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nesters/app/bloc/app_bloc.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/features/auth/bloc/auth_bloc.dart';
import 'package:nesters/features/home/bloc/home_bloc.dart';
import 'package:nesters/features/home/user/user_bloc.dart';
import 'package:nesters/features/user/edit-profile/cubit/edit_profile_cubit.dart';
import 'package:nesters/features/user/edit-profile/cubit/edit_profile_state.dart';
import 'package:nesters/theme/theme.dart';
import 'package:nesters/utils/extensions/extensions.dart';
import 'package:nesters/utils/widgets/custom_flat_button.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: AppTheme.bodyLarge),
        ),
        body: BlocProvider(
          create: (context) => UserBloc(
            context.read<AuthBloc>().state.maybeWhen(
                  authenticated: (user) => user,
                  orElse: () => throw Exception('User not authenticated'),
                ),
          ),
          child: const SafeArea(
            child: EditProfileView(),
          ),
        ),
      ),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  @override
  void initState() {
    super.initState();
    context.read<EditProfileCubit>().getUserProfile();
  }

  final ImagePicker _picker = ImagePicker();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController degreeNameController = TextEditingController();
  final TextEditingController personTypeController = TextEditingController();
  final TextEditingController workExperienceController =
      TextEditingController();
  final TextEditingController smokingHabitController = TextEditingController();
  final TextEditingController drinkingHabitController = TextEditingController();
  final TextEditingController foodHabitController = TextEditingController();
  final TextEditingController cookingSkillController = TextEditingController();
  final TextEditingController cleaningHabitController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController hobbiesController = TextEditingController();
  final TextEditingController flatmateGenderController =
      TextEditingController();
  final TextEditingController roomTypeController = TextEditingController();

  @override
  void dispose() {
    collegeNameController.dispose();
    degreeNameController.dispose();
    personTypeController.dispose();
    workExperienceController.dispose();
    smokingHabitController.dispose();
    drinkingHabitController.dispose();
    foodHabitController.dispose();
    cookingSkillController.dispose();
    cleaningHabitController.dispose();
    bioController.dispose();
    hobbiesController.dispose();
    flatmateGenderController.dispose();
    roomTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.userEditProfile != null) {
          if (state.isSuccessful) {
            context.showSuccessSnackBar('Profile updated successfully');
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            }
          } else if (state.isFailure) {
            context.showErrorSnackBar('Could not update profile');
          }
          collegeNameController.text =
              state.userEditProfile!.selectedCollegeName ?? '';
          degreeNameController.text =
              state.userEditProfile!.selectedCourseName ?? '';
          personTypeController.text =
              (state.userEditProfile!.personType ?? PersonType.UNKNOWN)
                  .toTextFieldValue();
          workExperienceController.text =
              state.userEditProfile!.workExperience.toString();
          smokingHabitController.text =
              state.userEditProfile!.smokingHabit.toString();
          drinkingHabitController.text =
              state.userEditProfile!.drinkingHabit.toString();
          foodHabitController.text =
              state.userEditProfile!.foodHabit.toString();
          cookingSkillController.text =
              state.userEditProfile!.cookingSkill.toString();
          cleaningHabitController.text =
              state.userEditProfile!.cleanlinessHabit.toString();
          bioController.text = state.userEditProfile!.bio;
          hobbiesController.text = state.userEditProfile!.hobbies;
          flatmateGenderController.text =
              (state.userEditProfile!.flatmatesGenderPrefs == "")
                  ? "No Preference"
                  : state.userEditProfile!.flatmatesGenderPrefs;
          roomTypeController.text = state.userEditProfile!.roomType.toUI();
        }
      },
      builder: (context, state) {
        return state.userEditProfile != null && !state.isLoading
            ? BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  return RawScrollbar(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    thumbColor: AppTheme.primary,
                    padding: const EdgeInsets.only(right: 4),
                    thumbVisibility: true,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.userEditProfile!.profileImage != null)
                                  _buildProfileImage(
                                    imageUrl:
                                        state.userEditProfile!.profileImage!,
                                    state: state,
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your University',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomSearchableDropDownField(
                                  controller: collegeNameController,
                                  asyncItems: (query) async {
                                    return userState.universities
                                        .where((element) =>
                                            element?.title
                                                ?.toLowerCase()
                                                .contains(
                                                    query.toLowerCase()) ??
                                            false)
                                        .toList();
                                  },
                                  hintText: 'Search for your college',
                                  filterFn: (item, query) =>
                                      item?.title
                                          ?.toLowerCase()
                                          .contains(query.toLowerCase()) ??
                                      false,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your Degree',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomSearchableDropDownField(
                                  controller: degreeNameController,
                                  asyncItems: (query) async {
                                    return userState.degrees
                                        .where((element) =>
                                            element?.name
                                                .toLowerCase()
                                                .contains(
                                                    query.toLowerCase()) ??
                                            false)
                                        .toList();
                                  },
                                  hintText: 'Search for your degree',
                                  filterFn: (item, query) =>
                                      item?.name
                                          ?.toLowerCase()
                                          .contains(query.toLowerCase()) ??
                                      false,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Person Type',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                CustomDropdownField(
                                  controller: personTypeController,
                                  items: PersonType.values
                                      .map((e) => e.toTextFieldValue())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Flatmate Gender Preference',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: flatmateGenderController,
                                  items: const [
                                    "Male",
                                    "Female",
                                    "Mixed",
                                    "No Preference",
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Room Type',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: roomTypeController,
                                  items: UserRoomType.values
                                      .map((e) => e.toUI())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Work Experience (in yrs)',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  controller: workExperienceController,
                                  hintText: 'Enter your work experience',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Smoking Habit',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: smokingHabitController,
                                  items: UserHabit.values
                                      .map((e) => e.toString())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Drinking Habit',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: drinkingHabitController,
                                  items: UserHabit.values
                                      .map((e) => e.toString())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Food Habit',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: foodHabitController,
                                  items: UserFoodHabit.values
                                      .map((e) => e.toString())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cooking Skill',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: cookingSkillController,
                                  items: UserCookingSkill.values
                                      .map((e) => e.toString())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cleaning Habit',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomDropdownField(
                                  controller: cleaningHabitController,
                                  items: UserCleanlinessHabit.values
                                      .map((e) => e.toString())
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Hobbies',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  controller: hobbiesController,
                                  hintText: 'Enter your hobbies',
                                  maxLines: 5,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bio',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  controller: bioController,
                                  hintText: 'Enter your bio',
                                  maxLines: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SaveButton(
                          isLoading: state.isSubmitting,
                          onPressed: () {
                            if (state.isSubmitting) return;
                            int? workExperience =
                                int.tryParse(workExperienceController.text);
                            if (workExperience == null) {
                              context.showSnackBar(
                                'Please enter a valid work experience',
                              );
                              return;
                            } else if (workExperience < 0) {
                              context.showSnackBar(
                                'Work experience cannot be negative',
                              );
                              return;
                            }
                            context.read<EditProfileCubit>().loadProfileData(
                                  selectedCollegeName:
                                      collegeNameController.text,
                                  selectedCourseName: degreeNameController.text,
                                  personType: PersonType.fromString(
                                      personTypeController.text),
                                  workExperience:
                                      int.parse(workExperienceController.text),
                                  smokingHabit: UserHabit.fromString(
                                      smokingHabitController.text),
                                  drinkingHabit: UserHabit.fromString(
                                      drinkingHabitController.text),
                                  foodHabit: UserFoodHabit.fromString(
                                      foodHabitController.text),
                                  cookingSkill: UserCookingSkill.fromString(
                                      cookingSkillController.text),
                                  cleanlinessHabit:
                                      UserCleanlinessHabit.fromString(
                                          cleaningHabitController.text),
                                  bio: bioController.text,
                                  hobbies: hobbiesController.text,
                                  flatmatesGenderPrefs:
                                      flatmateGenderController.text,
                                  roomType: UserRoomType.fromString(
                                      roomTypeController.text),
                                );
                            context
                                .read<EditProfileCubit>()
                                .updateProfileData();
                          },
                        )
                      ],
                    ),
                  );
                },
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildProfileImage({
    required String imageUrl,
    required EditProfileState state,
  }) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: state.imagePath != null
              ? Image.file(File(state.imagePath!)).image
              : NetworkImage(imageUrl),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          _buildOptionItem(
                            Icons.photo,
                            'Gallery',
                            () {
                              Navigator.pop(context);
                              _picker
                                  .pickImage(source: ImageSource.gallery)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    context
                                        .read<EditProfileCubit>()
                                        .updateProfileImage(value.path);
                                  });
                                }
                              });
                            },
                          ),
                          _buildOptionItem(
                            Icons.camera_alt,
                            'Camera',
                            () {
                              Navigator.pop(context);
                              _picker
                                  .pickImage(source: ImageSource.camera)
                                  .then((value) {
                                if (value != null) {
                                  context
                                      .read<EditProfileCubit>()
                                      .updateProfileImage(value.path);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      // Add more Row widgets for additional options as needed
                    ],
                  ),
                );
              },
            );
          },
          child: const Text('Change Profile Image'),
        ),
      ],
    ));
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
            ),
            Text(
              label,
            ),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const SaveButton(
      {super.key, required this.onPressed, required this.isLoading});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.all(16),
          child: CustomFlatButton(
            isLoading: widget.isLoading,
            onPressed: () {
              widget.onPressed();
            },
            text: 'Save',
            padding: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }
}
