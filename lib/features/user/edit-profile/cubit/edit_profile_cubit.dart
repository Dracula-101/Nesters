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

  void getUserProfile() {
    emit(state.copyWith(loadingState: state.loadingState?.loading()));
    if (_authRepository.currentUser == null) {
      emit(state.copyWith(loadingState: state.loadingState?.resetLoading()));
      return;
    }
    _userRepository.getUserProfile(_authRepository.currentUser!.id).then(
      (user) {
        emit(
          state.copyWith(
            loadingState: state.loadingState?.success(),
            profileImage: user.profileImage,
            selectedCollegeName: user.selectedCollegeName,
            selectedCourseName: user.selectedCourseName,
            personType: user.personType,
            workExperience: user.workExperience,
            smokingHabit: user.smokingHabit,
            drinkingHabit: user.drinkingHabit,
            foodHabit: user.foodHabit,
            cookingSkill: user.cookingSkill,
            cleanlinessHabit: user.cleanlinessHabit,
            bio: user.bio,
            hobbies: user.hobbies,
            flatmatesGenderPrefs: user.flatmatesGenderPrefs,
            roomType: user.roomType,
          ),
        );
      },
    ).catchError(
      (error) {
        _logger.error('Error getting user profile: $error');
        if (error is AppException) {
          emit(
            state.copyWith(
              loadingState: state.loadingState?.failure(error),
            ),
          );
        }
      },
    ).whenComplete(
      () {
        emit(state.copyWith(loadingState: state.loadingState?.resetLoading()));
      },
    );
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
      ),
    );
  }

  void updateProfileData() async {
    try {
      emit(state.copyWith(submitState: state.submitState?.loading()));
      if (_authRepository.currentUser == null) {
        emit(state.copyWith(
            submitState: state.submitState?.failure(UserNotAuthError())));
        return;
      }
      final userId = _authRepository.currentUser!.id;
      if (state.imagePath != null) {
        final imageUrl = await _userRepository.uploadProfileImage(
          state.imagePath!,
          userId,
        );
        emit(state.copyWith(profileImage: imageUrl));
      }
      if (state.userEditProfile == null) {
        emit(state.copyWith(submitState: state.submitState?.resetLoading()));
        return;
      }
      await _userRepository.updateProfile(state.userEditProfile!, userId);
      emit(state.copyWith(submitState: state.submitState?.success()));
    } on AppException catch (e) {
      _logger.error('Error updating profile: $e');
      emit(state.copyWith(submitState: state.submitState?.failure(e)));
    } finally {
      emit(state.copyWith(submitState: state.submitState?.resetLoading()));
    }
  }
}
