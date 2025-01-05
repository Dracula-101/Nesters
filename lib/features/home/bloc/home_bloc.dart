import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/network/network_checker_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeEvent>(_onEvent);
    _listenToNetwork();
  }

  final UserRepository _userRepository = GetIt.I<UserRepository>();
  final NetworkCheckerRepository _networkCheckerRepository =
      GetIt.I<NetworkCheckerRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();

  void _onEvent(HomeEvent event, Emitter<HomeState> emit) async {
    if (event is LoadProfileEvent) {
      emit(state.copyWith(isLoading: true));
    } else if (event is FetchNextPageEvent) {
      emit(state.copyWith(isLoading: true));
    } else if (event is LoadProfileCompleteEvent) {
      emit(state.copyWith(profiles: event.profiles, isLoading: false));
    } else if (event is LoadProfileErrorEvent) {
      emit(state.copyWith(error: event.error, isLoading: false));
    } else if (event is SingleAddFilterProfileEvent) {
      emit(state.copyWith(userFilter: null, isLoading: true));
      final filteredUser =
          await _userRepository.getSingleFilteredQuickProfiles(event.filter);
      emit(state.copyWith(
          filteredProfiles: filteredUser,
          isLoading: false,
          singleUserFilter: event.filter));
    } else if (event is SingleRemoveFilterProfileEvent) {
      emit(state.copyWith(singleUserFilter: null, filteredProfiles: null));
    } else if (event is AddFilterProfileEvent) {
    } else if (event is RemoveFilterProfileEvent) {
      emit(state.copyWith(
          userFilter: null, singleUserFilter: null, filteredProfiles: null));
    }
  }

  void _listenToNetwork() {
    _networkCheckerRepository.networkStatusStream.doOnData((event) {
      _logger.log(
        "Network Status: ${event.isOnline ? "Online" : "Offline"}, Type: ${event.networkData}",
      );
    }).listen(null);
  }
}
