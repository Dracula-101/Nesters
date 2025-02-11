// ignore_for_file: constant_identifier_names

part of 'request_bloc.dart';

class RequestUserState extends BlocState {
  RequestUserState({
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
    bool? isLoading,
    AppException? error,
    bool? isSuccess,
  }) {
    return RequestUserState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  RequestUserState loading() {
    return RequestUserState(
      isLoading: true,
      error: null,
      isSuccess: false,
    );
  }

  @override
  RequestUserState resetLoading() {
    return copyWith(isLoading: false);
  }

  @override
  RequestUserState failure(AppException error) {
    return RequestUserState(
      isLoading: false,
      error: error,
      isSuccess: false,
    );
  }

  @override
  RequestUserState success() {
    return RequestUserState(
      isLoading: false,
      error: null,
      isSuccess: true,
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
  final List<Request> requestSentUsers;
  final List<Request> requestReceivedUsers;
  final RequestUserState requestUserState;
  final RequestSendState requestSendState;

  RequestState({
    this.currentScreen = RequestScreen.RECEIVED,
    this.requestSentUsers = const [],
    this.requestReceivedUsers = const [],
    required this.requestUserState,
    required this.requestSendState,
  });

  RequestState copyWith({
    RequestScreen? currentScreen,
    List<Request>? requestSentUsers,
    List<Request>? requestReceivedUsers,
    RequestUserState? requestUserState,
    RequestSendState? requestSendState,
  }) {
    return RequestState(
      currentScreen: currentScreen ?? this.currentScreen,
      requestSentUsers: requestSentUsers ?? this.requestSentUsers,
      requestReceivedUsers: requestReceivedUsers ?? this.requestReceivedUsers,
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
