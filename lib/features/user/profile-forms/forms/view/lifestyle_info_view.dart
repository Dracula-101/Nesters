import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/features/user/profile-forms/forms/cubit/form_cubit.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class LifeStyleInfoPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final CurrentFormState currentFormState;
  const LifeStyleInfoPage(
      {super.key, required this.formKey, required this.currentFormState});

  @override
  State<LifeStyleInfoPage> createState() => _LifeStyleInfoPageState();
}

class _LifeStyleInfoPageState extends State<LifeStyleInfoPage> {
  // foodHabit;
  // cookingSkill;
  // drinkingHabit;
  // smokingHabit
  // cleanlinessHabit;
  // roomType

  final TextEditingController foodHabitController = TextEditingController();
  final TextEditingController cookingSkillController = TextEditingController();
  final TextEditingController drinkingHabitController = TextEditingController();
  final TextEditingController smokingHabitController = TextEditingController();
  final TextEditingController cleanlinessHabitController =
      TextEditingController();
  final TextEditingController hobbiesController = TextEditingController();
  final ValueNotifier<int> maxLines = ValueNotifier<int>(1);

  @override
  Widget build(BuildContext context) {
    return BlocListener<FormCubit, CurrentFormState>(
      listener: (context, state) {
        if (state.validationState.isLoading) {
          print(
              '${foodHabitController.text}, ${cookingSkillController.text}, ${drinkingHabitController.text}, ${smokingHabitController.text}, ${cleanlinessHabitController.text}, ${hobbiesController.text}');
          context.read<FormCubit>().addData(
                foodHabit: UserFoodHabit.fromString(foodHabitController.text),
                cookingSkill:
                    UserCookingSkill.fromString(cookingSkillController.text),
                drinkingHabit:
                    UserHabit.fromString(drinkingHabitController.text),
                smokingHabit: UserHabit.fromString(smokingHabitController.text),
                cleanlinessHabit: UserCleanlinessHabit.fromString(
                    cleanlinessHabitController.text),
                hobbies: hobbiesController.text,
              );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Form(
          key: widget.formKey,
          child: SingleChildScrollView(
              child: Column(
            children: [
              _buildFoodPreferenceField(),
              _buildSpacing(),
              _buildCookingProficiencyField(),
              _buildSpacing(),
              _buildDrinkingHabitField(),
              _buildSpacing(),
              _buildSmokingHabitField(),
              _buildSpacing(),
              _buildCleanlinessHabitField(),
              _buildSpacing(),
              _buildHobbiesField(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildHobbiesField() {
    return ValueListenableBuilder(
      valueListenable: maxLines,
      builder: (context, value, child) {
        return CustomTextField(
          controller: hobbiesController,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: 'Hobbies',
          labelText: 'Hobbies! 🎨',
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your hobbies';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              int expectedLines = (value.length / 25).ceil();
              maxLines.value = expectedLines;
            } else {
              maxLines.value = 1;
            }
          },
          alignLabelWithHint: true,
          maxLines: 5,
        );
      },
    );
  }

  CustomBottomSheetDropdownField<UserCleanlinessHabit>
      _buildCleanlinessHabitField() {
    return CustomBottomSheetDropdownField(
      controller: cleanlinessHabitController,
      hintText: 'Cleanliness Habit',
      labelText: 'Cleanliness Habit',
      prefixIcon: const Icon(
        Icons.clean_hands,
      ),
      items: UserCleanlinessHabit.safeValues,
      validator: (value) {
        if (value == null) {
          return 'Please select a cleanliness habit';
        }
        return null;
      },
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(
              cleanlinessHabit: UserCleanlinessHabit.fromString(value),
            );
      },
    );
  }

  CustomBottomSheetDropdownField<UserHabit> _buildSmokingHabitField() {
    return CustomBottomSheetDropdownField(
      controller: smokingHabitController,
      hintText: 'Smoking Habit',
      labelText: 'Smoking Habit',
      prefixIcon: const Icon(
        Icons.smoking_rooms,
      ),
      items: UserHabit.safeValues,
      validator: (value) {
        if (value == null) {
          return 'Please select a smoking habit';
        }
        return null;
      },
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(
              smokingHabit: UserHabit.fromString(value),
            );
      },
    );
  }

  CustomBottomSheetDropdownField<UserHabit> _buildDrinkingHabitField() {
    return CustomBottomSheetDropdownField(
      controller: drinkingHabitController,
      hintText: 'Drinking Habit',
      labelText: 'Drinking Habit',
      prefixIcon: const Icon(
        Icons.no_drinks,
      ),
      items: UserHabit.safeValues,
      validator: (value) {
        if (value == null) {
          return 'Please select a drinking habit';
        }
        return null;
      },
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(
              drinkingHabit: UserHabit.fromString(value),
            );
      },
    );
  }

  CustomBottomSheetDropdownField<UserCookingSkill>
      _buildCookingProficiencyField() {
    return CustomBottomSheetDropdownField(
      controller: cookingSkillController,
      hintText: 'Cooking Proficiency',
      labelText: 'Cooking Proficiency',
      prefixIcon: const Icon(
        Icons.restaurant,
      ),
      items: UserCookingSkill.safeValues,
      validator: (value) {
        if (value == null) {
          return 'Please select a cooking proficiency';
        }
        return null;
      },
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(
              cookingSkill: UserCookingSkill.fromString(value),
            );
      },
    );
  }

  Widget _buildSpacing() {
    return const SizedBox(height: 20);
  }

  CustomBottomSheetDropdownField<UserFoodHabit> _buildFoodPreferenceField() {
    return CustomBottomSheetDropdownField(
      controller: foodHabitController,
      hintText: 'Food Preference',
      labelText: 'Food Preference',
      prefixIcon: const Icon(
        Icons.restaurant_menu,
      ),
      items: UserFoodHabit.safeValues,
      validator: (value) {
        if (value == null) {
          return 'Please select a food preference';
        }
        return null;
      },
      onEditingComplete: (value) {
        context.read<FormCubit>().addData(
              foodHabit: UserFoodHabit.fromString(value),
            );
      },
    );
  }
}
