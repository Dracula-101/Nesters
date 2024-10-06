import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_filter_event.dart';
part 'user_filter_state.dart';
part 'user_filter_bloc.freezed.dart';

class UserFilterBloc extends Bloc<UserFilterEvent, UserFilterState> {
  UserFilterBloc() : super(_Initial()) {
    on<UserFilterEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
