import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/network/network_checker_repository.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/user/profile/user_filter.dart';
import 'package:nesters/domain/models/user/profile/user_info.dart';
import 'package:nesters/domain/models/user/profile/user_quick_profile.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:nesters/utils/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

part 'home_state.dart';
part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(HomeState(user: authRepository.currentUserInfo)) {
    on<HomeEvent>(_onEvent);
    _listenToNetwork();
    _addUserInfo();
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository = GetIt.I<UserRepository>();
  final NetworkCheckerRepository _networkCheckerRepository =
      GetIt.I<NetworkCheckerRepository>();
  final AppLogger _logger = GetIt.I<AppLogger>();

  void _onEvent(HomeEvent event, Emitter<HomeState> emit) async {
    if (event is LoadProfileEvent) {
      emit(state.copyWith(user: event.user));
    } else if (event is FetchNextPageEvent) {
      emit(state.copyWith(filterState: state.filterState.loading()));
    } else if (event is LoadProfileCompleteEvent) {
      emit(
        state.copyWith(filterState: state.filterState.success()),
      );
    } else if (event is LoadProfileErrorEvent) {
      emit(
        state.copyWith(filterState: state.filterState.failure(event.error)),
      );
    } else if (event is SingleAddFilterProfileEvent) {
      emit(
        state.copyWith(
          singleUserFilter: event.filter,
          filterState: state.filterState.loading(),
        ),
      );
      try {
        final filteredUser = await _userRepository
            .getSingleFilteredQuickProfiles(event.filter)
            .timeout(const Duration(minutes: 1));
        emit(
          state.copyWith(
            filteredProfiles: filteredUser,
            filterState: state.filterState.success(),
            singleUserFilter: event.filter,
          ),
        );
      } on AppException catch (e) {
        emit(
          state.copyWith(
            filterState: state.filterState.failure(e),
            singleUserFilter: null,
          ),
        );
      }
    } else if (event is SingleRemoveFilterProfileEvent) {
      emit(
        state.copyWith(singleUserFilter: null, filteredProfiles: null),
      );
    } else if (event is AddFilterProfileEvent) {
      if (event.filter == null) {
        emit(
          state.copyWith(
            userFilter: null,
            singleUserFilter: null,
            filteredProfiles: null,
            filterState: state.filterState.success(),
          ),
        );
        return;
      }
      emit(state.copyWith(
        filterState: state.filterState.loading(),
        userFilter: event.filter,
      ));
      try {
        final filteredUser = await _userRepository
            .getMultipleFilteredQuickProfiles(event.filter!)
            .timeout(const Duration(minutes: 1));
        _logger.debug(
            "Filtered User: ${filteredUser.length} with filter: ${event.filter}");
        emit(
          state.copyWith(
            filteredProfiles: filteredUser,
            filterState: state.filterState.success(),
            userFilter: event.filter,
          ),
        );
      } on AppException catch (e) {
        emit(
          state.copyWith(
              filterState: state.filterState.failure(e), userFilter: null),
        );
      }
    } else if (event is RemoveFilterProfileEvent) {
      emit(
        state.copyWith(
          userFilter: null,
          singleUserFilter: null,
          filteredProfiles: null,
        ),
      );
    }
  }

  void _listenToNetwork() {
    _networkCheckerRepository.networkStatusStream.doOnData((event) {
      _logger.log(
        "Network Status: ${event.isOnline ? "Online" : "Offline"}, Type: ${event.networkData}",
      );
    }).listen(null);
  }

  void _addUserInfo() {
    _authRepository.userInfo.asBroadcastStream().doOnData((event) {
      log("User Info Got: $event");
      if (event != null && !isClosed) {
        add(LoadProfileEvent(event));
      }
    }).listen(null);
  }
}
