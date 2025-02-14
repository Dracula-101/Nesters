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

  List<FieldValue> toFieldValues() {
    return [
      FieldValue(
        key: 'person_type',
        value: personType?.toSafeString(),
      ),
      FieldValue(
        key: 'bio',
        value: bio,
      ),
      FieldValue(
        key: 'primary_lang',
        value: primaryLang,
      ),
      FieldValue(
        key: 'other_lang',
        value: secondaryLang,
      ),
      FieldValue(
        key: 'undergrad_college_name',
        value: undergradCollegeName,
      ),
      FieldValue(
        key: 'work_experience',
        value: workExperience,
      ),
      FieldValue(
        key: 'food_habit',
        value: foodHabit?.toSafeString(),
      ),
      FieldValue(
        key: 'cooking_skill',
        value: cookingSkill?.toSafeString(),
      ),
      FieldValue(
        key: 'drinking_habit',
        value: drinkingHabit?.toSafeString(),
      ),
      FieldValue(
        key: 'smoking_habit',
        value: smokingHabit?.toSafeString(),
      ),
      FieldValue(
        key: 'cleanliness_habit',
        value: cleanlinessHabit?.toSafeString(),
      ),
      FieldValue(
        key: 'hobbies',
        value: hobbies,
      ),
      FieldValue(
        key: 'flatmates_gender_prefs',
        value: flatmateGenderPrefs,
      ),
      FieldValue(
        key: 'room_type',
        value: roomType?.toSafeString(),
      ),
    ];
  }
}
