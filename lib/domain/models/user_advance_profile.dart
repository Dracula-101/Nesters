import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';

import 'person_type.dart';
import 'user_habit.dart';

class UserAdvanceProfile extends Equatable {
  final String? id;
  final PersonType personType;
  final String bio;
  final String primaryLang;
  final Map<String, String> otherLang;
  final String city;
  final String state;
  final String undergradCollegeName;
  final int workExperience;
  final String foodHabit;
  final String cookingSkill;
  final UserHabit drinkingHabit;
  final UserHabit smokingHabit;
  final String cleanlinessHabit;
  final String hobbies;
  final String roomType;
  final String flatematesGenderPrefs;
  final Map<String, String>? socialMedia;

  const UserAdvanceProfile({
    required this.id,
    required this.personType,
    required this.bio,
    required this.primaryLang,
    required this.otherLang,
    required this.city,
    required this.state,
    required this.undergradCollegeName,
    required this.workExperience,
    required this.foodHabit,
    required this.cookingSkill,
    required this.drinkingHabit,
    required this.smokingHabit,
    required this.cleanlinessHabit,
    required this.hobbies,
    required this.roomType,
    required this.flatematesGenderPrefs,
    required this.socialMedia,
  });

  @override
  List<Object?> get props => [
        id,
        personType,
        bio,
        primaryLang,
        otherLang,
        city,
        state,
        undergradCollegeName,
        workExperience,
        foodHabit,
        cookingSkill,
        drinkingHabit,
        smokingHabit,
        cleanlinessHabit,
        hobbies,
        roomType,
        flatematesGenderPrefs,
        socialMedia,
      ];

  //toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_type': personType,
      'bio': bio,
      'primary_lang': primaryLang,
      'other_lang': otherLang,
      'city': city,
      'state': state,
      'undergrad_college_name': undergradCollegeName,
      'work_experience': workExperience,
      'food_habit': foodHabit,
      'cooking_skill': cookingSkill,
      'drinking_habit': drinkingHabit,
      'smoking_habit': smokingHabit,
      'cleanliness_habit': cleanlinessHabit,
      'hobbies': hobbies,
      'room_type': roomType,
      'flatmates_gender_prefs': flatematesGenderPrefs,
      'social_media': socialMedia,
    };
  }

  //toFieldValues
  List<FieldValue> toFieldValues() {
    return [
      FieldValue(key: 'id', value: id),
      FieldValue(key: 'person_type', value: personType.toString()),
      FieldValue(key: 'bio', value: bio),
      FieldValue(key: 'primary_lang', value: primaryLang),
      FieldValue(key: 'other_lang', value: otherLang),
      FieldValue(key: 'city', value: city),
      FieldValue(key: 'state', value: state),
      FieldValue(key: 'undergrad_college_name', value: undergradCollegeName),
      FieldValue(key: 'work_experience', value: workExperience),
      FieldValue(key: 'food_habit', value: foodHabit),
      FieldValue(key: 'cooking_skill', value: cookingSkill),
      FieldValue(key: 'drinking_habit', value: drinkingHabit.toString()),
      FieldValue(key: 'smoking_habit', value: smokingHabit.toString()),
      FieldValue(key: 'cleanliness_habit', value: cleanlinessHabit),
      FieldValue(key: 'hobbies', value: hobbies),
      FieldValue(key: 'room_type', value: roomType),
      FieldValue(key: 'flatmates_gender_prefs', value: flatematesGenderPrefs),
      FieldValue(key: 'social_media', value: socialMedia),
    ];
  }
}
