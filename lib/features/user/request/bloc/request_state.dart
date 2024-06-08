// ignore_for_file: constant_identifier_names

part of 'request_bloc.dart';

@freezed
class RequestState with _$RequestState {
  factory RequestState({
    @Default(RequestScreen.RECEIVED) RequestScreen currentScreen,
    @Default(false) bool isLoading,
    List<Request>? requestSentUsers,
    List<Request>? requestReceivedUsers,
    Exception? error,
    @Default(false) bool requestSentSuccess,
    @Default(false) bool requestSentError,
  }) = _RequestState;

  factory RequestState.initial() => RequestState(
        isLoading: false,
      );

  factory RequestState.loading() => RequestState(
        isLoading: true,
      );

  factory RequestState.error(Exception error) => RequestState(
        isLoading: false,
        error: error,
      );
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
