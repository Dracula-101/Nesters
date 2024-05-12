import 'package:flutter/material.dart';
import 'package:nesters/domain/models/room_type.dart';
import 'package:nesters/domain/models/user_habit.dart';
import 'package:nesters/utils/widgets/widgets.dart';

class LifeStyleInfoPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onContinue;
  final Function(UserFoodHabit, UserCookingSkill, UserHabit, UserHabit,
      UserCleanlinessHabit, UserRoomType) onSaved;
  const LifeStyleInfoPage(
      {super.key,
      required this.formKey,
      required this.onSaved,
      required this.onContinue});

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: widget.formKey,
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
      controller: foodHabitController,
      hintText: 'Cleanliness Habit',
      labelText: 'Cleanliness Habit',
      prefixIcon: const Icon(
        Icons.clean_hands,
      ),
      items: UserCleanlinessHabit.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a cleanliness habit';
        }
        return null;
      },
    );
  }

  CustomBottomSheetDropdownField<UserHabit> _buildSmokingHabitField() {
    return CustomBottomSheetDropdownField(
      controller: foodHabitController,
      hintText: 'Smoking Habit',
      labelText: 'Smoking Habit',
      prefixIcon: const Icon(
        Icons.smoking_rooms,
      ),
      items: UserHabit.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a smoking habit';
        }
        return null;
      },
    );
  }

  CustomBottomSheetDropdownField<UserHabit> _buildDrinkingHabitField() {
    return CustomBottomSheetDropdownField(
      controller: foodHabitController,
      hintText: 'Drinking Habit',
      labelText: 'Drinking Habit',
      prefixIcon: const Icon(
        Icons.no_drinks,
      ),
      items: UserHabit.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a drinking habit';
        }
        return null;
      },
    );
  }

  CustomBottomSheetDropdownField<UserCookingSkill>
      _buildCookingProficiencyField() {
    return CustomBottomSheetDropdownField(
      controller: foodHabitController,
      hintText: 'Cooking Proficiency',
      labelText: 'Cooking Proficiency',
      prefixIcon: const Icon(
        Icons.restaurant,
      ),
      items: UserCookingSkill.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a cooking proficiency';
        }
        return null;
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
      items: UserFoodHabit.values,
      validator: (value) {
        if (value == null) {
          return 'Please select a food preference';
        }
        return null;
      },
    );
  }
}
