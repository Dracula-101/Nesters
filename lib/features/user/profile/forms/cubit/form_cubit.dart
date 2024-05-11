import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesters/domain/models/person_type.dart';
import 'package:nesters/domain/models/user.dart';
import 'package:nesters/domain/models/user_habit.dart';

part 'form_state.dart';
part 'form_cubit.freezed.dart';

class FormCubit extends Cubit<CurrentFormState> {
  FormCubit() : super(CurrentFormState.initial());

  // 1st stage - personal info
  void setPersonalInfo(
    PersonType personType,
    String primaryLang,
    List<String> secondaryLangs,
  ) {}

  // 2nd stage - lifestyle
  // 3rd stage - background
}
