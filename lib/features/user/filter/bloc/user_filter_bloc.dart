import 'package:bloc/bloc.dart';

part 'user_filter_event.dart';
part 'user_filter_state.dart';

class UserFilterBloc extends Bloc<UserFilterEvent, UserFilterState> {
  UserFilterBloc() : super(UserFilterState()) {
    on<UserFilterEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
