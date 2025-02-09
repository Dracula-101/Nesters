// ignore_for_file: constant_identifier_names

part of 'request_bloc.dart';

class RequestUserState extends BlocState {
  final List<Request> requestSentUsers;
  final List<Request> requestReceivedUsers;

  RequestUserState({
    this.requestSentUsers = const [],
    this.requestReceivedUsers = const [],
    bool isLoading = false,
    AppException? error,
    bool isSuccess = false,
  }) : super(
          isLoading: isLoading,
          exception: error,
          isSuccess: isSuccess,
        );

  @override
  RequestUserState copyWith({
    List<Request>? requestSentUsers,
    List<Request>? requestReceivedUsers,
    bool? isLoading,
    AppException? error,
    bool? isSuccess,
  }) {
    return RequestUserState(
      requestSentUsers: requestSentUsers ?? this.requestSentUsers,
      requestReceivedUsers: requestReceivedUsers ?? this.requestReceivedUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  RequestUserState loading() {
    return copyWith(
      requestSentUsers: requestSentUsers,
      requestReceivedUsers: requestReceivedUsers,
      isLoading: true,
      error: null,
      isSuccess: false,
    );
  }

  @override
  RequestUserState resetLoading() {
    return copyWith(isLoading: false);
  }

  RequestUserState loadUserSuccess({
    required List<Request> requestSentUsers,
    required List<Request> requestReceivedUsers,
  }) {
    return copyWith(
      requestSentUsers: requestSentUsers,
      requestReceivedUsers: requestReceivedUsers,
      isLoading: false,
      error: null,
      isSuccess: true,
    );
  }

  @override
  RequestUserState failure(AppException error) {
    return copyWith(
      requestSentUsers: requestSentUsers,
      requestReceivedUsers: requestReceivedUsers,
      isLoading: false,
      error: error,
      isSuccess: false,
    );
  }
}

class RequestSendState extends BlocState {
  RequestSendState({
    bool isLoading = false,
    AppException? error,
    bool isSuccess = false,
  }) : super(
          isLoading: isLoading,
          exception: error,
          isSuccess: isSuccess,
        );

  @override
  RequestSendState copyWith(
      {bool? isLoading, AppException? error, bool? isSuccess}) {
    return RequestSendState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  RequestSendState failure(AppException error) {
    return copyWith(
      isLoading: false,
      error: error,
      isSuccess: false,
    );
  }

  @override
  RequestSendState loading() {
    return copyWith(
      isLoading: true,
      error: null,
      isSuccess: false,
    );
  }

  @override
  RequestSendState resetLoading() {
    return copyWith(isLoading: false);
  }

  RequestSendState success() {
    return copyWith(
      isLoading: false,
      error: null,
      isSuccess: true,
    );
  }
}

class RequestState {
  final RequestScreen currentScreen;
  final RequestUserState requestUserState;
  final RequestSendState requestSendState;

  RequestState({
    this.currentScreen = RequestScreen.RECEIVED,
    required this.requestUserState,
    required this.requestSendState,
  });

  RequestState copyWith({
    RequestScreen? currentScreen,
    RequestUserState? requestUserState,
    RequestSendState? requestSendState,
  }) {
    return RequestState(
      currentScreen: currentScreen ?? this.currentScreen,
      requestUserState: requestUserState ?? this.requestUserState,
      requestSendState: requestSendState ?? this.requestSendState,
    );
  }
}

enum RequestScreen {
  SENT,
  RECEIVED;

  String get name {
    switch (this) {
      case SENT:
        return 'Sent';
      case RECEIVED:
        return 'Received';
    }
  }

  int get indexValue {
    switch (this) {
      case SENT:
        return 0;
      case RECEIVED:
        return 1;
    }
  }
}
