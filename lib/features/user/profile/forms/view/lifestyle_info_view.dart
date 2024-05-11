import 'package:flutter/material.dart';
import 'package:nesters/domain/models/person_type.dart';
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
  final TextEditingController roomTypeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          CustomBottomSheetDropdownField(
            controller: foodHabitController,
            hintText: 'Food Habits',
            labelText: 'Cooking Skill',
            prefixIcon: const Icon(
              Icons.location_city,
            ),
            items: PersonType.values,
            validator: (value) {
              if (value == null) {
                return 'Please select a city';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
