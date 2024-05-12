import 'package:flutter/material.dart';
import 'package:nesters/domain/models/person_type.dart';
import 'package:nesters/domain/models/room_type.dart';
import 'package:nesters/domain/models/user_habit.dart';
import 'package:nesters/domain/models/room_type.dart';
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
  final TextEditingController roomTypeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
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
          _buildRoomTypeField(),
          _buildSpacing(),
          _buildFlatemateGenderField(),
        ],
      ),
    );
  }

  CustomBottomSheetDropdownField<FlatmateGenderType>
      _buildFlatemateGenderField() {
    return CustomBottomSheetDropdownField(
      controller: foodHabitController,
      hintText: 'Flatemate\'s Gender Pref..',
      labelText: 'Flatemate\'s Gender Pref..',
      prefixIcon: const Icon(
        Icons.clean_hands,
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
      controller: foodHabitController,
      hintText: 'Room Preference',
      labelText: 'Room Preference',
      prefixIcon: const Icon(
        Icons.clean_hands,
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
