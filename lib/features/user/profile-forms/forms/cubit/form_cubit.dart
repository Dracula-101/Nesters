import 'package:bloc/bloc.dart';

import 'package:nesters/domain/models/user/person_type.dart';
import 'package:nesters/domain/models/user/pref/user_habit.dart';
import 'package:nesters/domain/models/user/user.dart';

part 'form_state.dart';

class FormCubit extends Cubit<CurrentFormState> {
  FormCubit() : super(CurrentFormState.initial());

  int totalQuestions = 15;

  int checkVariables(List<String?> variables) {
    int count = 0;
    for (String? variable in variables) {
      if (variable == null || variable.isEmpty == true) {
        count++;
      }
    }
    return count;
  }

  void checkFirstStage({
    String? personType,
    String? primaryLang,
    String? secondaryLang,
    String? bio,
  }) {
    List<String?> questions = [personType, primaryLang, secondaryLang, bio];
    int inCompleteQuestions = checkVariables(questions);
    emit(state.copyWith(
      questionsComplete: questions.length - inCompleteQuestions,
    ));
  }

  void checkSecondStage({
    String? userHabit,
    String? userHabit2,
    String? userHabit3,
    String? userHabit4,
    String? userHabit5,
  }) {
    List<String?> questions = [
      userHabit,
      userHabit2,
      userHabit3,
      userHabit4,
      userHabit5,
    ];
    int inCompleteQuestions = checkVariables(questions);
    emit(state.copyWith(
      questionsComplete: questions.length - inCompleteQuestions,
    ));
  }

  void checkThirdStage({
    String? userHabit6,
    String? userHabit7,
    String? userHabit8,
    String? userHabit9,
    String? userHabit10,
  }) {
    List<String?> questions = [
      userHabit6,
      userHabit7,
      userHabit8,
      userHabit9,
      userHabit10,
    ];
    int inCompleteQuestions = checkVariables(questions);
    emit(state.copyWith(
      questionsComplete: questions.length - inCompleteQuestions,
    ));
  }

  void validatePage() {}
}
