import 'package:equatable/equatable.dart';
import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/pref/user_intake.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';
import 'package:nesters/utils/bloc_state.dart';

class EditProfileState extends Equatable {
  final UserEditProfile? userEditProfile;
  final BlocState loadingState;
  final BlocState submitState;
  final String? imagePath;

  const EditProfileState({
    this.userEditProfile,
    this.loadingState = const BlocState(),
    this.submitState = const BlocState(isLoading: false),
    this.imagePath,
  });

  EditProfileState copyWith({
    String? imagePath,
    BlocState? loadingState,
    BlocState? submitState,
    String? profileImage,
    String? selectedCollegeName,
    String? selectedCourseName,
    PersonType? personType,
    int? workExperience,
    UserHabit? smokingHabit,
    UserHabit? drinkingHabit,
    UserFoodHabit? foodHabit,
    UserCookingSkill? cookingSkill,
    UserCleanlinessHabit? cleanlinessHabit,
    String? bio,
    String? hobbies,
    String? flatmatesGenderPrefs,
    UserRoomType? roomType,
    UserIntake? intakePeriod,
    int? intakeYear,
  }) {
    return EditProfileState(
      imagePath: imagePath ?? this.imagePath,
      loadingState: loadingState ?? this.loadingState,
      submitState: submitState ?? this.submitState,
      userEditProfile: UserEditProfile(
        profileImage: profileImage ?? userEditProfile?.profileImage,
        selectedCollegeName:
            selectedCollegeName ?? userEditProfile?.selectedCollegeName,
        selectedCourseName:
            selectedCourseName ?? userEditProfile?.selectedCourseName,
        personType: personType ?? userEditProfile?.personType,
        workExperience: workExperience ?? userEditProfile?.workExperience ?? 0,
        smokingHabit:
            smokingHabit ?? userEditProfile?.smokingHabit ?? UserHabit.UNKNOWN,
        drinkingHabit: drinkingHabit ??
            userEditProfile?.drinkingHabit ??
            UserHabit.UNKNOWN,
        foodHabit:
            foodHabit ?? userEditProfile?.foodHabit ?? UserFoodHabit.UNKNOWN,
        cookingSkill: cookingSkill ??
            userEditProfile?.cookingSkill ??
            UserCookingSkill.UNKNOWN,
        cleanlinessHabit: cleanlinessHabit ??
            userEditProfile?.cleanlinessHabit ??
            UserCleanlinessHabit.UNKNOWN,
        bio: bio ?? userEditProfile?.bio ?? '',
        hobbies: hobbies ?? userEditProfile?.hobbies ?? '',
        flatmatesGenderPrefs:
            flatmatesGenderPrefs ?? userEditProfile?.flatmatesGenderPrefs ?? '',
        roomType: roomType ?? userEditProfile?.roomType ?? UserRoomType.UNKNOWN,
        intakePeriod: intakePeriod ?? userEditProfile?.intakePeriod,
        intakeYear:
            intakeYear ?? userEditProfile?.intakeYear ?? DateTime.now().year,
      ),
    );
  }

  @override
  String toString() {
    return 'EditProfileState(userEditProfile: $userEditProfile), loadingState: $loadingState, imagePath: $imagePath, submitState: $submitState)';
  }

  @override
  List<Object?> get props => [
        userEditProfile,
        loadingState,
        imagePath,
        submitState,
      ];
}

class UserEditProfile {
  final String? profileImage;
  final String? selectedCollegeName;
  final String? selectedCourseName;
  final PersonType? personType;
  final int workExperience;
  final UserHabit smokingHabit;
  final UserHabit drinkingHabit;
  final UserFoodHabit foodHabit;
  final UserCookingSkill cookingSkill;
  final UserCleanlinessHabit cleanlinessHabit;
  final String bio;
  final String hobbies;
  final String flatmatesGenderPrefs;
  final UserRoomType roomType;
  final UserIntake? intakePeriod;
  final int? intakeYear;

  const UserEditProfile({
    required this.profileImage,
    required this.selectedCollegeName,
    required this.selectedCourseName,
    required this.personType,
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
    required this.intakePeriod,
    required this.intakeYear,
  });

  UserEditProfile copyWith({
    String? profileImage,
    String? selectedCollegeName,
    String? selectedCourseName,
    PersonType? personType,
    int? workExperience,
    UserHabit? smokingHabit,
    UserHabit? drinkingHabit,
    UserFoodHabit? foodHabit,
    UserCookingSkill? cookingSkill,
    UserCleanlinessHabit? cleanlinessHabit,
    String? bio,
    String? hobbies,
    String? flatmatesGenderPrefs,
    UserRoomType? roomType,
    UserIntake? intakePeriod,
    int? intakeYear,
  }) {
    return UserEditProfile(
      profileImage: profileImage ?? this.profileImage,
      selectedCollegeName: selectedCollegeName ?? this.selectedCollegeName,
      selectedCourseName: selectedCourseName ?? this.selectedCourseName,
      personType: personType ?? this.personType,
      workExperience: workExperience ?? this.workExperience,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      foodHabit: foodHabit ?? this.foodHabit,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      cleanlinessHabit: cleanlinessHabit ?? this.cleanlinessHabit,
      bio: bio ?? this.bio,
      hobbies: hobbies ?? this.hobbies,
      flatmatesGenderPrefs: flatmatesGenderPrefs ?? this.flatmatesGenderPrefs,
      roomType: roomType ?? this.roomType,
      intakePeriod: intakePeriod ?? this.intakePeriod,
      intakeYear: intakeYear ?? this.intakeYear,
    );
  }

  @override
  String toString() {
    return 'UserEditProfile(profileImage: $profileImage, selectedCollegeName: $selectedCollegeName, selectedCourseName: $selectedCourseName, personType: $personType, workExperience: $workExperience, smokingHabit: $smokingHabit, drinkingHabit: $drinkingHabit, foodHabit: $foodHabit, cookingSkill: $cookingSkill, cleanlinessHabit: $cleanlinessHabit, bio: $bio, hobbies: $hobbies, flatmatesGenderPrefs: $flatmatesGenderPrefs, roomType: $roomType, intakePeriod: $intakePeriod, intakeYear: $intakeYear)';
  }

  List<FieldValue> toFieldValues() {
    return [
      FieldValue(
        key: "profile_image",
        value: profileImage,
      ),
      FieldValue(
        key: "selected_college_name",
        value: selectedCollegeName,
      ),
      FieldValue(
        key: "selected_course_name",
        value: selectedCourseName,
      ),
      FieldValue(
        key: "person_type",
        value: personType?.toSafeString(),
      ),
      FieldValue(
        key: "work_experience",
        value: workExperience,
      ),
      FieldValue(
        key: "smoking_habit",
        value: smokingHabit.toSafeString(),
      ),
      FieldValue(
        key: "drinking_habit",
        value: drinkingHabit.toSafeString(),
      ),
      FieldValue(
        key: "food_habit",
        value: foodHabit.toSafeString(),
      ),
      FieldValue(
        key: "cooking_skill",
        value: cookingSkill.toSafeString(),
      ),
      FieldValue(
        key: "cleanliness_habit",
        value: cleanlinessHabit.toSafeString(),
      ),
      FieldValue(
        key: "bio",
        value: bio,
      ),
      FieldValue(
        key: "hobbies",
        value: hobbies,
      ),
      FieldValue(key: "flatmates_gender_prefs", value: flatmatesGenderPrefs),
      FieldValue(
        key: "room_type",
        value: roomType.toSafeString(),
      ),
      FieldValue(
        key: "intake_period",
        value: intakePeriod.toString(),
      ),
      FieldValue(
        key: "intake_year",
        value: intakeYear,
      ),
    ];
  }
}
