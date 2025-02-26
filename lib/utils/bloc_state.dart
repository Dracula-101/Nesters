import 'package:nesters/data/repository/utils/app_exception.dart';

class BlocState {
  final bool isLoading;
  final AppException? exception;
  final bool isSuccess;

  const BlocState({
    this.isLoading = true,
    this.exception,
    this.isSuccess = false,
  });

  BlocState copyWith({
    bool? isLoading,
    AppException? exception,
    bool? isSuccess,
  }) {
    return BlocState(
      isLoading: isLoading ?? this.isLoading,
      exception: exception ?? this.exception,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  BlocState loading() {
    return const BlocState(
      isLoading: true,
      exception: null,
      isSuccess: false,
    );
  }

  BlocState resetLoading() {
    return const BlocState(
      isLoading: false,
      exception: null,
      isSuccess: false,
    );
  }

  BlocState failure(AppException error) {
    return BlocState(
      isLoading: false,
      exception: error,
      isSuccess: false,
    );
  }

  BlocState success() {
    return const BlocState(
      isLoading: false,
      exception: null,
      isSuccess: true,
    );
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^ exception.hashCode ^ isSuccess.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          exception == other.exception &&
          isSuccess == other.isSuccess;

  @override
  String toString() {
    return '\nisLoading: $isLoading,\nexception: $exception,\nisSuccess: $isSuccess';
  }
}
