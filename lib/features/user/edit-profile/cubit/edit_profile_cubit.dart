import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/room/room_type.dart';
import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/utils/logger/logger.dart';

import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(const EditProfileState());

  final UserRepository _userRepository = GetIt.I<UserRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();

  Future<void> getUserProfile() async {
    emit(state.copyWith(loadingState: state.loadingState.loading()));
    if (_authRepository.currentUser == null) {
      emit(state.copyWith(loadingState: state.loadingState.resetLoading()));
      return;
    }
    try {
      final userProfile =
          await _userRepository.getUserProfile(_authRepository.currentUser!.id);
      log("User Profile: $userProfile");
      emit(
        state.copyWith(
          loadingState: state.loadingState.success(),
          profileImage: userProfile.profileImage,
          selectedCollegeName: userProfile.selectedCollegeName,
          selectedCourseName: userProfile.selectedCourseName,
          personType: userProfile.personType,
          workExperience: userProfile.workExperience,
          smokingHabit: userProfile.smokingHabit,
          drinkingHabit: userProfile.drinkingHabit,
          foodHabit: userProfile.foodHabit,
          cookingSkill: userProfile.cookingSkill,
          cleanlinessHabit: userProfile.cleanlinessHabit,
          bio: userProfile.bio,
          hobbies: userProfile.hobbies,
          flatmatesGenderPrefs: userProfile.flatmatesGenderPrefs,
          roomType: userProfile.roomType,
          intakePeriod: userProfile.intakePeriod,
          intakeYear: userProfile.intakeYear,
        ),
      );
    } catch (error) {
      _logger.error('Error getting user profile: $error');
      if (error is AppException) {
        emit(
          state.copyWith(loadingState: state.loadingState.failure(error)),
        );
      }
    } finally {
      emit(
        state.copyWith(loadingState: state.loadingState.resetLoading()),
      );
    }
  }

  void updateProfileImage(String imagePath) {
    emit(state.copyWith(imagePath: imagePath));
  }

  void loadProfileData({
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
    String? intakePeriod,
    int? intakeYear,
  }) {
    emit(
      state.copyWith(
        profileImage: profileImage,
        selectedCollegeName: selectedCollegeName,
        selectedCourseName: selectedCourseName,
        personType: personType,
        workExperience: workExperience,
        smokingHabit: smokingHabit,
        drinkingHabit: drinkingHabit,
        foodHabit: foodHabit,
        cookingSkill: cookingSkill,
        cleanlinessHabit: cleanlinessHabit,
        bio: bio,
        hobbies: hobbies,
        flatmatesGenderPrefs: flatmatesGenderPrefs,
        roomType: roomType,
        intakePeriod: intakePeriod,
        intakeYear: intakeYear,
      ),
    );
  }

  void updateProfileData() async {
    try {
      emit(state.copyWith(submitState: state.submitState.loading()));
      if (_authRepository.currentUser == null) {
        emit(state.copyWith(
            submitState: state.submitState.failure(UserNotAuthError())));
        return;
      }
      final userId = _authRepository.currentUser!.id;
      if (state.imagePath != null) {
        final imageUrl = await _userRepository.uploadProfileImage(
          state.imagePath!,
          userId,
          previousImageUrl: _authRepository.currentUser!.photoUrl,
        );
        emit(state.copyWith(profileImage: imageUrl));
        log("Uploaded Image: $imageUrl");
      }
      if (state.userEditProfile == null) {
        emit(state.copyWith(submitState: state.submitState.resetLoading()));
        return;
      }
      await _userRepository.updateProfile(state.userEditProfile!, userId);
      emit(state.copyWith(submitState: state.submitState.success()));
      await _authRepository.updateUserInfo(
        _authRepository.currentUserInfo
            ?.copyWith(profileImage: state.userEditProfile?.profileImage),
      );
      log("Profile Updated Succesfully");
    } on AppException catch (e) {
      _logger.error('Error updating profile: $e');
      emit(state.copyWith(submitState: state.submitState.failure(e)));
    }
  }
}
