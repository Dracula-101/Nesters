part of 'form_cubit.dart';

@freezed
class CurrentFormState with _$CurrentFormState {
  const factory CurrentFormState({
    required User user,
    required String id,
    required PersonType personType,
    required String bio,
    required String primaryLang,
    required String otherLang,
    required String city,
    required String state,
    required String undergradCollegeName,
    required int workExperience,
    required String foodHabit,
    required String cookingSkill,
    required UserHabit drinkingHabit,
    required UserHabit smokingHabit,
    required String cleanlinessHabit,
    required String hobbies,
    required String roomType,
    required int questionsComplete,
  }) = _CurrentFormState;

  factory CurrentFormState.initial() => CurrentFormState(
        user: User.empty(),
        id: '',
        personType: PersonType.AMBIVERT,
        bio: '',
        primaryLang: '',
        otherLang: '',
        city: '',
        state: '',
        undergradCollegeName: '',
        workExperience: 0,
        foodHabit: '',
        cookingSkill: '',
        drinkingHabit: UserHabit.NEVER,
        smokingHabit: UserHabit.NEVER,
        cleanlinessHabit: '',
        hobbies: '',
        roomType: '',
        questionsComplete: 0,
      );
}
