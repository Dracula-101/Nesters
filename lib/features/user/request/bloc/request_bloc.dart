import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/profile/user_chat_profile_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/user/request/request.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:nesters/features/auth/bloc/auth_error.dart';
import 'package:nesters/features/user/request/bloc/request_bloc_error.dart';
import 'package:nesters/utils/bloc_state.dart';
import 'package:rxdart/rxdart.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  RequestBloc() : super(RequestState()) {
    on<RequestEvent>(_onRequestEvent);
    authRepository.user.listen((user) {
      if (user != null) {
        add(const RequestEvent.loadUsers());
      }
    });
  }

  final chatRepository = GetIt.I<UserChatProfileRepository>();
  final authRepository = GetIt.I<AuthRepository>();

  StreamSubscription<List<Request>>? _sentRequestSubscription;
  StreamSubscription<List<Request>>? _receivedRequestSubscription;

  Future<void> _onRequestEvent(
    RequestEvent event,
    Emitter<RequestState> emit,
  ) async {
    await event.when(
      started: () {
        emit(
            state.copyWith(requestUserState: state.requestUserState.loading()));
        return Future.value();
      },
      changeScreen: (value) {
        emit(state.copyWith(currentScreen: value));
        return Future.value();
      },
      loadUsers: () async {
        await _loadUsers(emit);
      },
      acceptRequest: (String receiverId) async {
        await _acceptRequest(receiverId, emit);
        await _loadUsers(emit);
      },
      rejectRequest: (String receiverId) async {
        await _rejectRequest(receiverId, emit);
        await _loadUsers(emit);
      },
      sendRequest: (userId) async {
        await _sendRequest(userId, emit);
        await _loadUsers(emit);
      },
      cancelRequest: (String userId) {
        return Future.value();
      },
      clearSentRequestStatus: () {
        emit(state.copyWith(requestSendState: BlocState()));
        return Future.value();
      },
    );
  }

  bool doesRequestExist(String userId) {
    bool isRequestSent =
        state.requestSentUsers.any((element) => element.receiver.id == userId);
    return isRequestSent;
  }

  Future<void> _loadUsers(Emitter<RequestState> emit) async {
    try {
      emit(state.copyWith(requestUserState: state.requestUserState.loading()));
      User? user = authRepository.currentUser;
      if (user == null) {
        return;
      }
      await emit.forEach(
        Rx.combineLatest2(
          chatRepository.getSentUserRequests(user),
          chatRepository.getReceivedUserRequests(user),
          (List<Request> sent, List<Request> received) => [sent, received],
        ),
        onData: (data) {
          return state.copyWith(
            requestSentUsers: data[0],
            requestReceivedUsers: data[1],
            requestUserState: state.requestUserState.success(),
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            requestUserState:
                state.requestUserState.failure(RequestStreamError()),
          );
        },
      );
    } on AppException catch (e) {
      emit(state.copyWith(
          requestUserState:
              state.requestUserState.failure(GetUserRequestError())));
    } finally {
      emit(state.copyWith(
          requestUserState: state.requestUserState.copyWith(isLoading: false)));
    }
  }

  Future<void> _sendRequest(String userId, Emitter<RequestState> emit) async {
    try {
      emit(state.copyWith(requestSendState: state.requestSendState.loading()));
      User? user = authRepository.currentUser;
      if (user == null) {
        return;
      }
      if (doesRequestExist(userId)) {
        emit(state.copyWith(
            requestSendState:
                state.requestSendState.failure(RequestAlreadySentError())));
        return;
      }
      await chatRepository.sendRequest(user.id, userId);
      emit(state.copyWith(requestSendState: state.requestSendState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(requestSendState: state.requestSendState.failure(e)));
    } finally {
      emit(state.copyWith(
          requestSendState: state.requestSendState.resetLoading()));
    }
  }

  Future<void> _acceptRequest(
      String receiverId, Emitter<RequestState> emit) async {
    try {
      emit(state.copyWith(
          requestAcceptState: state.requestAcceptState.loading()));
      User? user = authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
            requestAcceptState:
                state.requestAcceptState.failure(UserNotAuthError())));
        return;
      }
      await chatRepository.acceptRequest(user.id, receiverId);
      await chatRepository.createChatRoom(user.id, receiverId);
      emit(state.copyWith(
          requestAcceptState: state.requestAcceptState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(
          requestAcceptState: state.requestAcceptState.failure(e)));
    } finally {
      emit(state.copyWith(
          requestAcceptState: state.requestAcceptState.resetLoading()));
    }
  }

  Future<void> _rejectRequest(
    String receiverId,
    Emitter<RequestState> emit,
  ) async {
    try {
      emit(state.copyWith(
          requestDeclineState: state.requestDeclineState.loading()));
      User? user = authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
            requestDeclineState:
                state.requestDeclineState.failure(UserNotAuthError())));
        return;
      }
      await chatRepository.rejectRequest(user.id, receiverId);
      emit(state.copyWith(
          requestDeclineState: state.requestDeclineState.success()));
    } on AppException catch (e) {
      emit(state.copyWith(
          requestDeclineState: state.requestDeclineState.failure(e)));
    } finally {
      emit(state.copyWith(
          requestDeclineState: state.requestDeclineState.resetLoading()));
    }
  }

  @override
  Future<void> close() {
    _sentRequestSubscription?.cancel();
    _receivedRequestSubscription?.cancel();
    return super.close();
  }
}
