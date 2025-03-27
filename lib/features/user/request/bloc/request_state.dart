// ignore_for_file: constant_identifier_names

part of 'request_bloc.dart';

class RequestState {
  final RequestScreen currentScreen;
  final List<Request> requestSentUsers;
  final List<Request> requestReceivedUsers;
  final BlocState requestUserState;
  final BlocState requestSendState;

  RequestState({
    this.currentScreen = RequestScreen.RECEIVED,
    this.requestSentUsers = const [],
    this.requestReceivedUsers = const [],
    this.requestUserState = const BlocState(isLoading: false),
    this.requestSendState = const BlocState(isLoading: false),
  });

  RequestState copyWith({
    RequestScreen? currentScreen,
    List<Request>? requestSentUsers,
    List<Request>? requestReceivedUsers,
    BlocState? requestUserState,
    BlocState? requestSendState,
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
