import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';

class EditProfileState {
  final UserEditProfile? userEditProfile;
  final bool isLoading;
  final String? imagePath;
  final bool isSubmitting;
  final bool isSuccessful;
  final bool isFailure;

  const EditProfileState({
    this.userEditProfile,
    this.isLoading = true,
    this.imagePath,
    this.isSubmitting = false,
    this.isSuccessful = false,
    this.isFailure = false,
  });

  EditProfileState copyWith({
    bool? isLoading,
    String? imagePath,
    bool? isSubmitting,
    bool? isSuccessful,
    bool? isFailure,
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
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      imagePath: imagePath ?? this.imagePath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      isFailure: isFailure ?? this.isFailure,
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
      ),
    );
  }

  @override
  String toString() {
    return 'EditProfileState(userEditProfile: $userEditProfile, isLoading: $isLoading, isSubmitting: $isSubmitting)';
  }
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
    );
  }

  @override
  String toString() {
    return 'UserEditProfile(profileImage: $profileImage, selectedCollegeName: $selectedCollegeName, selectedCourseName: $selectedCourseName, personType: $personType, workExperience: $workExperience, smokingHabit: $smokingHabit, drinkingHabit: $drinkingHabit, foodHabit: $foodHabit, cookingSkill: $cookingSkill, cleanlinessHabit: $cleanlinessHabit, bio: $bio, hobbies: $hobbies, flatmatesGenderPrefs: $flatmatesGenderPrefs, roomType: $roomType)';
  }
}
