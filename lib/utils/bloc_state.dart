import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class BlocState {
  final bool isLoading;
  final AppException? exception;
  final bool isSuccess;

  BlocState({
    this.isLoading = false,
    this.exception,
    this.isSuccess = false,
  });

  BlocState copyWith({
    bool? isLoading,
    AppException? error,
    bool? isSuccess,
  });

  BlocState loading();

  BlocState resetLoading();

  BlocState failure(AppException error);

  BlocState success();

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
