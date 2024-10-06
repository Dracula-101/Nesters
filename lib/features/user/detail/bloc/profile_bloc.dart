import 'dart:developer';

import 'package:bloc/bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/user/user_repository.dart';
import 'package:nesters/domain/models/user/profile/user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileEvent>(_onProfileEvent);
  }

  final UserRepository _userRepository = GetIt.I<UserRepository>();

  Future<void> _onProfileEvent(
      ProfileEvent event, Emitter<ProfileState> emit) async {
    await event.when(
      load: (userId) async => await _loadUserProfile(userId, emit),
    );
  }

  Future<void> _loadUserProfile(String userId, Emitter<ProfileState> emit) {
    emit(state.copyWith(isLoading: true));
    return _userRepository.getUserProfile(userId).then(
      (userProfile) {
        emit(
          state.copyWith(
            userProfile: userProfile,
          ),
        );
      },
    ).catchError(
      (error) {
        if (error is Exception) {
          emit(
            state.copyWith(
              error: error,
            ),
          );
        } else {
          emit(
            state.copyWith(
              error: Exception(
                'An error occurred',
              ),
            ),
          );
        }
      },
    ).whenComplete(
      () {
        emit(
          state.copyWith(
            isLoading: false,
          ),
        );
      },
    );
  }
}
