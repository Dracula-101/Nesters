import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/domain/models/person_type.dart';
import 'package:nesters/domain/models/user.dart';
import 'package:nesters/domain/models/user_habit.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'form_state.dart';
part 'form_cubit.freezed.dart';

class FormCubit extends Cubit<CurrentFormState> {
  FormCubit() : super(CurrentFormState.initial());

  int totalQuestions = 17;

  void checkFirstStage({
    String? personType,
    String? primaryLang,
    String? secondaryLang,
    String? city,
    String? indianState,
    String? bio,
  }) {
    List<String?> questions = [
      personType,
      primaryLang,
      secondaryLang,
      city,
      indianState,
      bio
    ];
    int inCompleteQuestions = checkVariables(questions);
    GetIt.I<AppLoggerService>().info(
        'personType: $personType, primaryLang: $primaryLang, secondaryLang: $secondaryLang, city: $city, indianState: $indianState, bio: $bio');
    emit(state.copyWith(
      questionsComplete: questions.length - inCompleteQuestions,
    ));
  }

  int checkVariables(List<String?> variables) {
    int count = 0;
    for (String? variable in variables) {
      if (variable == null || variable.isEmpty == true) {
        count++;
      }
    }
    return count;
  }

  // 1st stage - personal info
  void setPersonalInfo(
    PersonType personType,
    String primaryLang,
    List<String> secondaryLangs,
  ) {}

  // 2nd stage - lifestyle
  // 3rd stage - background
}
