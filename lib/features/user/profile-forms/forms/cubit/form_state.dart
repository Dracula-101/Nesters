part of 'form_cubit.dart';

class CurrentFormState {
  final UserFormProfile userFormProfile;
  final int currentPage;
  final bool firstPageComplete;
  final bool secondPageComplete;
  final bool thirdPageComplete;
  final BlocState validationState;
  final BlocState submitState;

  CurrentFormState({
    required this.userFormProfile,
    this.currentPage = 0,
    this.firstPageComplete = false,
    this.secondPageComplete = false,
    this.thirdPageComplete = false,
    this.validationState = const BlocState(isLoading: false),
    this.submitState = const BlocState(isLoading: false),
  });

  factory CurrentFormState.initial() =>
      CurrentFormState(userFormProfile: UserFormProfile());

  CurrentFormState copyWith({
    UserFormProfile? userFormProfile,
    int? currentPage,
    bool? isValidating,
    bool? firstPageComplete,
    bool? secondPageComplete,
    bool? thirdPageComplete,
    BlocState? validationState,
    BlocState? submitState,
  }) {
    return CurrentFormState(
      userFormProfile: userFormProfile ?? this.userFormProfile,
      currentPage: currentPage ?? this.currentPage,
      firstPageComplete: firstPageComplete ?? this.firstPageComplete,
      secondPageComplete: secondPageComplete ?? this.secondPageComplete,
      thirdPageComplete: thirdPageComplete ?? this.thirdPageComplete,
      validationState: validationState ?? this.validationState,
      submitState: submitState ?? this.submitState,
    );
  }

  @override
  String toString() {
    return userFormProfile.toString();
  }
}

class UserFormProfile {
  final PersonType? personType;
  final String? bio;
  final String? primaryLang;
  final String? secondaryLang;
  final String? undergradCollegeName;
  final int? workExperience;
  final UserFoodHabit? foodHabit;
  final UserCookingSkill? cookingSkill;
  final UserHabit? drinkingHabit;
  final UserHabit? smokingHabit;
  final UserCleanlinessHabit? cleanlinessHabit;
  final String? hobbies;
  final String? flatmateGenderPrefs;
  final UserRoomType? roomType;

  UserFormProfile({
    this.personType,
    this.bio,
    this.primaryLang,
    this.secondaryLang,
    this.undergradCollegeName,
    this.workExperience,
    this.foodHabit,
    this.cookingSkill,
    this.drinkingHabit,
    this.smokingHabit,
    this.flatmateGenderPrefs,
    this.cleanlinessHabit,
    this.hobbies,
    this.roomType,
  });

  //copy with
  UserFormProfile copyWith({
    PersonType? personType,
    String? bio,
    String? primaryLang,
    String? secondaryLang,
    String? undergradCollegeName,
    int? workExperience,
    UserFoodHabit? foodHabit,
    UserCookingSkill? cookingSkill,
    UserHabit? drinkingHabit,
    UserHabit? smokingHabit,
    String? flatmateGenderPrefs,
    UserCleanlinessHabit? cleanlinessHabit,
    String? hobbies,
    UserRoomType? roomType,
  }) {
    return UserFormProfile(
      personType: personType ?? this.personType,
      bio: bio ?? this.bio,
      primaryLang: primaryLang ?? this.primaryLang,
      secondaryLang: secondaryLang ?? this.secondaryLang,
      undergradCollegeName: undergradCollegeName ?? this.undergradCollegeName,
      workExperience: workExperience ?? this.workExperience,
      foodHabit: foodHabit ?? this.foodHabit,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      flatmateGenderPrefs: flatmateGenderPrefs ?? this.flatmateGenderPrefs,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      cleanlinessHabit: cleanlinessHabit ?? this.cleanlinessHabit,
      hobbies: hobbies ?? this.hobbies,
      roomType: roomType ?? this.roomType,
    );
  }

  @override
  String toString() {
    return 'UserFormProfile{personType: $personType, bio: $bio, primaryLang: $primaryLang, secondaryLang: $secondaryLang, undergradCollegeName: $undergradCollegeName, workExperience: $workExperience, foodHabit: $foodHabit, cookingSkill: $cookingSkill, drinkingHabit: $drinkingHabit, smokingHabit: $smokingHabit, cleanlinessHabit: $cleanlinessHabit, hobbies: $hobbies, flatmateGenderPrefs: $flatmateGenderPrefs, roomType: $roomType}';
  }

  // to map based on field values
  Map<String, dynamic> toMap() {
    return {
      'person_type': personType?.toSafeString(),
      'bio': bio,
      'primary_lang': primaryLang,
      'other_lang': secondaryLang,
      'undergrad_college_name': undergradCollegeName,
      'work_experience': workExperience,
      'food_habit': foodHabit?.toSafeString(),
      'cooking_skill': cookingSkill?.toSafeString(),
      'drinking_habit': drinkingHabit?.toSafeString(),
      'smoking_habit': smokingHabit?.toSafeString(),
      'cleanliness_habit': cleanlinessHabit?.toSafeString(),
      'hobbies': hobbies,
      'flatmates_gender_prefs': flatmateGenderPrefs,
      'room_type': roomType?.toSafeString(),
    };
  }
}
