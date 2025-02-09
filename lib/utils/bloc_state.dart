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
}
