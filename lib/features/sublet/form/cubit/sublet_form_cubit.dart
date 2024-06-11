import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesters/domain/models/sublet/sublet_model.dart';

part 'sublet_form_state.dart';
part 'sublet_form_cubit.freezed.dart';

class SubletFormCubit extends Cubit<SubletFormState> {
  SubletFormCubit() : super(SubletFormState.initial());

  void validatePage() {
    int currentPage = state.pageNumber;
    emit(state.copyWith(validatingPage: -1));
    emit(state.copyWith(validatingPage: currentPage));
  }

  void onPageChange(int pageNumber) {
    emit(state.copyWith(pageNumber: pageNumber));
  }

  void showPageValid(int page) {
    if (page == 1) {
      emit(state.copyWith(hasSecondPageAccess: true));
    } else if (page == 2) {
      emit(state.copyWith(hasThirdPageAccess: true));
    }
  }
}
