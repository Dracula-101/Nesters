part of 'form_cubit.dart';

class CurrentFormState {
  final User? user;
  final String? id;
  final PersonType? personType;
  final String? bio;
  final String? primaryLang;
  final String? otherLang;
  final String? city;
  final String? state;
  final String? undergradCollegeName;
  final int? workExperience;
  final String? foodHabit;
  final String? cookingSkill;
  final UserHabit? drinkingHabit;
  final UserHabit? smokingHabit;
  final String? cleanlinessHabit;
  final String? hobbies;
  final String? roomType;
  final int? questionsComplete;

  CurrentFormState({
    required this.user,
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
    required this.questionsComplete,
  });

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

  CurrentFormState copyWith({
    User? user,
    String? id,
    PersonType? personType,
    String? bio,
    String? primaryLang,
    String? otherLang,
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
    int? questionsComplete,
  }) {
    return CurrentFormState(
      user: user ?? this.user,
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
      questionsComplete: questionsComplete ?? this.questionsComplete,
    );
  }
}
