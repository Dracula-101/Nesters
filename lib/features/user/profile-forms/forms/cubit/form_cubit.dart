import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/language.dart';
import 'package:nesters/domain/models/room/room_type.dart';

import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'form_state.dart';

class FormCubit extends Cubit<CurrentFormState> {
  FormCubit() : super(CurrentFormState.initial());

  AppLogger logger = GetIt.I<AppLogger>();
  UserRepository userRepository = GetIt.I<UserRepository>();
  AuthRepository authRepository = GetIt.I<AuthRepository>();

  void validatePage() {
    emit(state.copyWith(
      validationState: state.validationState.loading(),
    ));
  }

  void confirmPage(int page) {
    emit(state.copyWith(
      firstPageComplete: page == 0,
      secondPageComplete: page == 1,
      thirdPageComplete: page == 2,
      currentPage: page,
      validationState: state.validationState.success(),
    ));
  }

  void addData({
    String? personType,
    String? primaryLang,
    String? secondaryLang,
    String? bio,
    UserFoodHabit? foodHabit,
    UserCookingSkill? cookingSkill,
    UserHabit? drinkingHabit,
    UserHabit? smokingHabit,
    UserCleanlinessHabit? cleanlinessHabit,
    String? hobbies,
    UserRoomType? roomType,
    String? flatmateGenderPrefs,
    String? underGradCollegeName,
    int? workExp,
  }) {
    emit(
      state.copyWith(
        userFormProfile: state.userFormProfile.copyWith(
          personType:
              personType == null ? null : PersonType.fromString(personType),
          primaryLang: primaryLang,
          secondaryLang: secondaryLang,
          bio: bio,
          foodHabit: foodHabit,
          cookingSkill: cookingSkill,
          drinkingHabit: drinkingHabit,
          smokingHabit: smokingHabit,
          cleanlinessHabit: cleanlinessHabit,
          hobbies: hobbies,
          roomType: roomType,
          flatmateGenderPrefs: flatmateGenderPrefs,
          undergradCollegeName: underGradCollegeName,
          workExperience: workExp,
        ),
        validationState: const BlocState(isLoading: false),
      ),
    );
    logger.info('User form profile updated: ${state.userFormProfile}');
  }

  Future<void> submitForm() async {
    try {
      if (state.submitState.isLoading) return;
      emit(state.copyWith(
        submitState: state.submitState.loading(),
      ));
      await userRepository.completeProfileInfo(state.userFormProfile);
      await authRepository.updateUserInfo(
        authRepository.currentUserInfo?.copyWith(
          roomType: state.userFormProfile.roomType,
          primaryLang: Language(name: state.userFormProfile.primaryLang ?? ''),
          otherLang: Language(name: state.userFormProfile.secondaryLang ?? ''),
          bio: state.userFormProfile.bio,
          foodHabit: state.userFormProfile.foodHabit,
          cookingSkill: state.userFormProfile.cookingSkill,
          drinkingHabit: state.userFormProfile.drinkingHabit,
          smokingHabit: state.userFormProfile.smokingHabit,
          cleanlinessHabit: state.userFormProfile.cleanlinessHabit,
          hobbies: state.userFormProfile.hobbies,
          flatmatesGenderPrefs: state.userFormProfile.flatmateGenderPrefs,
          undergradCollegeName: state.userFormProfile.undergradCollegeName,
          workExperience: state.userFormProfile.workExperience,
        ),
      );
      emit(state.copyWith(
        submitState: state.submitState.success(),
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        submitState: state.submitState.failure(e),
      ));
    }
  }
}
