import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String profileImage;
  final String city;
  final String state;
  final String selectedCollegeName;
  final String selectedCourseName;
  final String gender;
  final String undergradCollegeName;
  final DateTime? birthDate;
  final String personType;
  final String primaryLang;
  final String otherLang;
  final int workExperience;
  final String smokingHabit;
  final String drinkingHabit;
  final String foodHabit;
  final String cookingSkill;
  final String cleanlinessHabit;
  final String bio;
  final String hobbies;
  final String flatmatesGenderPrefs;
  final String roomType;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.city,
    required this.state,
    required this.selectedCollegeName,
    required this.selectedCourseName,
    required this.gender,
    required this.undergradCollegeName,
    required this.birthDate,
    required this.personType,
    required this.primaryLang,
    required this.otherLang,
    required this.workExperience,
    required this.smokingHabit,
    required this.drinkingHabit,
    required this.foodHabit,
    required this.cookingSkill,
    required this.cleanlinessHabit,
    required this.bio,
    required this.hobbies,
    required this.flatmatesGenderPrefs,
    required this.roomType,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        profileImage,
        city,
        state,
        selectedCollegeName,
        selectedCourseName,
        gender,
        undergradCollegeName,
        birthDate,
        personType,
        primaryLang,
        otherLang,
        workExperience,
        smokingHabit,
        drinkingHabit,
        foodHabit,
        cookingSkill,
        cleanlinessHabit,
        bio,
        hobbies,
        flatmatesGenderPrefs,
        roomType,
      ];

  List<FieldValue> toFieldValues() {
    return [
      FieldValue(key: 'id', value: id),
      FieldValue(key: 'full_name', value: fullName),
      FieldValue(key: 'profile_image', value: profileImage),
      FieldValue(key: 'city', value: city),
      FieldValue(key: 'state', value: state),
      FieldValue(key: 'selected_course_name', value: selectedCourseName),
      FieldValue(key: 'selected_college_name', value: selectedCollegeName),
      FieldValue(key: 'gender', value: gender),
      FieldValue(key: 'undergrad_college_name', value: undergradCollegeName),
      FieldValue(key: 'birth_date', value: birthDate),
      FieldValue(key: 'person_type', value: personType),
      FieldValue(key: 'primary_lang', value: primaryLang),
      FieldValue(key: 'other_lang', value: otherLang),
      FieldValue(key: 'work_experience', value: workExperience),
      FieldValue(key: 'smoking_habit', value: smokingHabit),
      FieldValue(key: 'drinking_habit', value: drinkingHabit),
      FieldValue(key: 'food_habit', value: foodHabit),
      FieldValue(key: 'cooking_skill', value: cookingSkill),
      FieldValue(key: 'cleanliness_habit', value: cleanlinessHabit),
      FieldValue(key: 'bio', value: bio),
      FieldValue(key: 'hobbies', value: hobbies),
      FieldValue(key: 'flatmates_gender_prefs', value: flatmatesGenderPrefs),
      FieldValue(key: 'room_type', value: roomType),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profile_image': profileImage,
      'city': city,
      'state': state,
      'selected_course_name': selectedCourseName,
      'selected_college_name': selectedCollegeName,
      'gender': gender,
      'undergrad_college_name': undergradCollegeName,
      'birth_date': birthDate,
      'person_type': personType,
      'primary_lang': primaryLang,
      'other_lang': otherLang,
      'work_experience': workExperience,
      'smoking_habit': smokingHabit,
      'drinking_habit': drinkingHabit,
      'food_habit': foodHabit,
      'cooking_skill': cookingSkill,
      'cleanliness_habit': cleanlinessHabit,
      'bio': bio,
      'hobbies': hobbies,
      'flatmates_gender_prefs': flatmatesGenderPrefs,
      'room_type': roomType,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      profileImage: json['profile_image'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      selectedCourseName: json['selected_course_name'] as String,
      selectedCollegeName: json['selected_college_name'] as String,
      gender: json['gender'] as String,
      undergradCollegeName: json['undergrad_college_name'] as String,
      birthDate: json['birth_date'] as DateTime?,
      personType: json['person_type'] as String,
      primaryLang: json['primary_lang'] as String,
      otherLang: json['other_lang'] as String,
      workExperience: json['work_experience'] as int,
      smokingHabit: json['smoking_habit'] as String,
      drinkingHabit: json['drinking_habit'] as String,
      foodHabit: json['food_habit'] as String,
      cookingSkill: json['cooking_skill'] as String,
      cleanlinessHabit: json['cleanliness_habit'] as String,
      bio: json['bio'] as String,
      hobbies: json['hobbies'] as String,
      flatmatesGenderPrefs: json['flatmates_gender_prefs'] as String,
      roomType: json['room_type'] as String,
    );
  }
}
