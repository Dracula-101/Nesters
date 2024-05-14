import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user_quick_profile.dart';
import 'package:nesters/utils/logger/logger.dart';

part 'home_state.dart';
part 'home_event.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    on<HomeEvent>(_onEvent);
  }

  final UserRepository _userRepository = GetIt.I<UserRepository>();

  void _onEvent(HomeEvent event, Emitter<HomeState> emit) {
    event.when(
      initial: (){},
      loaded: (pagingController) {
        if(pagingController.error!=null){
          emit(state.copyWith(profiles: pagingController.value.itemList ?? [], isLoading: false));
        }else {
          emit(state.copyWith(error: pagingController.error, isLoading: false));
        }
      },
      fetchNextPage: (profiles){
          emit(state.copyWith(profiles: profiles, isLoading: false));
        
      },
      loading: () async {
        emit(state.copyWith(isLoading: true));
      },
    );
  }

}
