import 'package:equatable/equatable.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';

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
  final String? imageUrl;

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
    required this.imageUrl,
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
        imageUrl,
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
      'image_url': imageUrl,
    };
  }

  //copyWith
  UserAdvanceProfile copyWith({
    String? id,
    PersonType? personType,
    String? bio,
    String? primaryLang,
    Map<String, String>? otherLang,
    String? city,
    String? state,
    String? undergradCollegeName,
    int? workExperience,
    String? foodHabit,
    String? cookingSkill,
    UserHabit? drinkingHabit,
    UserHabit? smokingHabit,
    String? cleanlinessHabit,
    String? hobbies,
    String? roomType,
    String? flatematesGenderPrefs,
    Map<String, String>? socialMedia,
    String? imageUrl,
  }) {
    return UserAdvanceProfile(
      id: id ?? this.id,
      personType: personType ?? this.personType,
      bio: bio ?? this.bio,
      primaryLang: primaryLang ?? this.primaryLang,
      otherLang: otherLang ?? this.otherLang,
      city: city ?? this.city,
      state: state ?? this.state,
      undergradCollegeName: undergradCollegeName ?? this.undergradCollegeName,
      workExperience: workExperience ?? this.workExperience,
      foodHabit: foodHabit ?? this.foodHabit,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      cleanlinessHabit: cleanlinessHabit ?? this.cleanlinessHabit,
      hobbies: hobbies ?? this.hobbies,
      roomType: roomType ?? this.roomType,
      flatematesGenderPrefs:
          flatematesGenderPrefs ?? this.flatematesGenderPrefs,
      socialMedia: socialMedia ?? this.socialMedia,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  //fromJson
  factory UserAdvanceProfile.fromJson(Map<String, dynamic> json) {
    return UserAdvanceProfile(
      id: json['id'] as String?,
      personType: PersonType.values
          .firstWhere((e) => e.toString() == json['person_type']),
      bio: json['bio'] as String,
      primaryLang: json['primary_lang'] as String,
      otherLang: Map<String, String>.from(json['other_lang']),
      city: json['city'] as String,
      state: json['state'] as String,
      undergradCollegeName: json['undergrad_college_name'] as String,
      workExperience: json['work_experience'] as int,
      foodHabit: json['food_habit'] as String,
      cookingSkill: json['cooking_skill'] as String,
      drinkingHabit: UserHabit.values
          .firstWhere((e) => e.toString() == json['drinking_habit']),
      smokingHabit: UserHabit.values
          .firstWhere((e) => e.toString() == json['smoking_habit']),
      cleanlinessHabit: json['cleanliness_habit'] as String,
      hobbies: json['hobbies'] as String,
      roomType: json['room_type'] as String,
      flatematesGenderPrefs: json['flatmates_gender_prefs'] as String,
      socialMedia: json['social_media'] != null
          ? Map<String, String>.from(json['social_media'])
          : null,
      imageUrl: json['profile_image'] as String?,
    );
  }
}
