import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/auth/auth_repository.dart';
import 'package:nesters/data/repository/user/firebase_user_repository.dart';
import 'package:nesters/domain/models/user/request/request.dart';
import 'package:nesters/domain/models/user/user.dart';
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

  final chatRepository = GetIt.I<UserChatRepository>();
  final authRepository = GetIt.I<AuthRepository>();

  StreamSubscription<List<Request>>? _sentRequestSubscription;
  StreamSubscription<List<Request>>? _receivedRequestSubscription;

  Future<void> _onRequestEvent(
    RequestEvent event,
    Emitter<RequestState> emit,
  ) async {
    await event.when(
      started: () {
        emit(RequestState(isLoading: true));
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
        emit(state.copyWith(
          requestSentSuccess: false,
          requestSentError: false,
        ));
        return Future.value();
      },
    );
  }

  bool doesRequestExist(String userId) {
    bool isRequestSent = state.requestSentUsers
            ?.any((element) => element.receiver.id == userId) ??
        false;
    return isRequestSent;
  }

  Future<void> _loadUsers(Emitter<RequestState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      User? user = authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
            error: Exception('User not found'), isLoading: false));
        return;
      }
      await emit.forEach(
        Rx.combineLatest2(
          chatRepository.getSentUserRequests(user),
          chatRepository.getReceivedUserRequests(user),
          (List<Request> sent, List<Request> received) => [sent, received],
        ),
        onData: (data) {
          return RequestState(
            requestSentUsers: data[0],
            requestReceivedUsers: data[1],
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(error: error as Exception);
        },
      );
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _sendRequest(String userId, Emitter<RequestState> emit) async {
    try {
      emit(RequestState(isLoading: true));
      User? user = authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
            error: Exception('User not found'), isLoading: false));
        return;
      }
      if (doesRequestExist(userId)) {
        emit(state.copyWith(
            error: Exception('Request already sent'),
            isLoading: false,
            requestSentError: true));
        return;
      }
      await chatRepository.sendRequest(user.id, userId);
      emit(state.copyWith(requestSentSuccess: true));
    } on Exception catch (e) {
      emit(state.copyWith(error: e, requestSentError: true));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _acceptRequest(
      String receiverId, Emitter<RequestState> emit) async {
    try {
      emit(RequestState(isLoading: true));
      User? user = authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
            error: Exception('User not found'), isLoading: false));
        return;
      }
      await chatRepository.acceptRequest(user.id, receiverId);
      await _createChatRoom(user.id, receiverId, emit);
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _createChatRoom(
    String senderId,
    String receiverId,
    Emitter<RequestState> emit,
  ) async {
    try {
      await chatRepository.createChatRoom(senderId, receiverId);
    } on Exception catch (e) {
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  Future<void> _rejectRequest(
    String receiverId,
    Emitter<RequestState> emit,
  ) async {
    try {
      emit(RequestState(isLoading: true));
      User? user = authRepository.currentUser;
      if (user == null) {
        emit(state.copyWith(
            error: Exception('User not found'), isLoading: false));
        return;
      }
      await chatRepository.rejectRequest(user.id, receiverId);
    } on Exception catch (e) {
      emit(state.copyWith(error: e));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _sentRequestSubscription?.cancel();
    _receivedRequestSubscription?.cancel();
    return super.close();
  }
}
