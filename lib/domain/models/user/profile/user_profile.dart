import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/domain/models/location/indian_city.dart';
import 'package:nesters/domain/models/location/indian_state.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/user.dart';

class UserProfile extends Equatable {
  final String? id;
  final String? fullName;
  final String? profileImage; //changeable
  final City? city;
  final IndianState? state;
  final String? selectedCollegeName; //changeable
  final String? selectedCourseName; //changeable
  final String? gender;
  final String? undergradCollegeName;
  final DateTime? birthDate;
  final PersonType? personType; //changeable
  final Language? primaryLang;
  final Language? otherLang;
  final int workExperience; //changeable
  final UserHabit smokingHabit; //changeable
  final UserHabit drinkingHabit; //changeable
  final UserFoodHabit foodHabit; //changeable
  final UserCookingSkill cookingSkill; //changeable
  final UserCleanlinessHabit cleanlinessHabit; //changeable
  final String bio; //changeable
  final String hobbies; //changeable
  final String flatmatesGenderPrefs; //changeable
  final UserRoomType roomType; //changeable

  const UserProfile({
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
      'city': city.toString(),
      'state': state.toString(),
      'selected_course_name': selectedCourseName,
      'selected_college_name': selectedCollegeName,
      'gender': gender,
      'undergrad_college_name': undergradCollegeName,
      'birth_date': birthDate?.toIso8601String(),
      'person_type': personType?.toString(),
      'primary_lang': primaryLang.toString(),
      'other_lang': otherLang.toString(),
      'work_experience': workExperience,
      'smoking_habit': smokingHabit.toString(),
      'drinking_habit': drinkingHabit.toString(),
      'food_habit': foodHabit.toString(),
      'cooking_skill': cookingSkill.toString(),
      'cleanliness_habit': cleanlinessHabit.toString(),
      'bio': bio,
      'hobbies': hobbies,
      'flatmates_gender_prefs': flatmatesGenderPrefs,
      'room_type': roomType.toString(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        id: json['id'] ?? '',
        fullName: json['full_name'] ?? '',
        profileImage: json['profile_image'] ?? '',
        city: City(name: json['city'] ?? ''),
        state: IndianState(name: json['state'] ?? ''),
        selectedCourseName: json['selected_course_name'] ?? '',
        selectedCollegeName: json['selected_college_name'] ?? '',
        gender: json['gender'] ?? '',
        undergradCollegeName: json['undergrad_college_name'] ?? '',
        birthDate: json['birth_date'] != null
            ? DateTime.tryParse(json['birth_date'])
            : null,
        personType: json['person_type'] != null
            ? PersonType.fromString(json['person_type'])
            : null,
        primaryLang: json['primary_lang'] != null
            ? Language(name: json['primary_lang'])
            : null,
        otherLang: json['other_lang'] != null
            ? Language(name: json['other_lang'])
            : null,
        workExperience: json['work_experience'] ?? 0,
        smokingHabit: json['smoking_habit'] != null
            ? UserHabit.fromString(json['smoking_habit'])
            : UserHabit.UNKNOWN,
        drinkingHabit: json['drinking_habit'] != null
            ? UserHabit.fromString(json['drinking_habit'])
            : UserHabit.UNKNOWN,
        foodHabit: json['food_habit'] != null
            ? UserFoodHabit.fromString(json['food_habit'])
            : UserFoodHabit.UNKNOWN,
        cookingSkill: json['cooking_skill'] != null
            ? UserCookingSkill.fromString(json['cooking_skill'])
            : UserCookingSkill.UNKNOWN,
        cleanlinessHabit: json['cleanliness_habit'] != null
            ? UserCleanlinessHabit.fromString(json['cleanliness_habit'])
            : UserCleanlinessHabit.UNKNOWN,
        bio: json['bio'] ?? '',
        hobbies: json['hobbies'] ?? '',
        flatmatesGenderPrefs: json['flatmates_gender_prefs'] ?? '',
        roomType: json['room_type'] != null
            ? UserRoomType.fromString(json['room_type'])
            : UserRoomType.UNKNOWN,
      );
    } on Exception catch (e) {
      throw Exception('Error parsing user profile: $e');
    }
  }

  UserQuickProfile toUserQuickProfile() {
    return UserQuickProfile(
      id: id,
      fullName: fullName,
      city: city,
      state: state,
      selectedCollegeName: selectedCollegeName,
      selectedCourseName: selectedCourseName,
      profileImage: profileImage,
      workExperience: workExperience,
    );
  }

  User toUser() {
    return User(
      id: id ?? '',
      fullName: fullName ?? '',
      email: '',
      photoUrl: profileImage ?? '',
      accessToken: '',
      isProfileCompleted: true,
      isProfileCreated: true,
    );
  }
}
