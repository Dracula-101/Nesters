// ignore_for_file: constant_identifier_names

part of 'request_bloc.dart';

class RequestState {
  final RequestScreen currentScreen;
  final bool isLoading;
  final List<Request>? requestSentUsers;
  final List<Request>? requestReceivedUsers;
  final Exception? error;
  final bool requestSentSuccess;
  final bool requestSentError;

  RequestState({
    this.currentScreen = RequestScreen.RECEIVED,
    this.isLoading = false,
    this.requestSentUsers,
    this.requestReceivedUsers,
    this.error,
    this.requestSentSuccess = false,
    this.requestSentError = false,
  });

  RequestState copyWith({
    RequestScreen? currentScreen,
    bool? isLoading,
    List<Request>? requestSentUsers,
    List<Request>? requestReceivedUsers,
    Exception? error,
    bool? requestSentSuccess,
    bool? requestSentError,
  }) {
    return RequestState(
      currentScreen: currentScreen ?? this.currentScreen,
      isLoading: isLoading ?? this.isLoading,
      requestSentUsers: requestSentUsers ?? this.requestSentUsers,
      requestReceivedUsers: requestReceivedUsers ?? this.requestReceivedUsers,
      error: error ?? this.error,
      requestSentSuccess: requestSentSuccess ?? this.requestSentSuccess,
      requestSentError: requestSentError ?? this.requestSentError,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RequestState &&
        other.currentScreen == currentScreen &&
        other.isLoading == isLoading &&
        listEquals(other.requestSentUsers, requestSentUsers) &&
        listEquals(other.requestReceivedUsers, requestReceivedUsers) &&
        other.error == error &&
        other.requestSentSuccess == requestSentSuccess &&
        other.requestSentError == requestSentError;
  }

  @override
  int get hashCode =>
      currentScreen.hashCode ^
      isLoading.hashCode ^
      requestSentUsers.hashCode ^
      requestReceivedUsers.hashCode ^
      error.hashCode ^
      requestSentSuccess.hashCode ^
      requestSentError.hashCode;
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
