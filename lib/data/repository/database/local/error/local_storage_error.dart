// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

enum LocalStorageErrorCode {
  OBJECT_MISMATCH,
  OBJECT_SAVE,
  OBJECT_CLEAR,
  STORAGE_CLEAR_ERR,
  STORAGE_ERR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

abstract class LocalStorageError implements AppException {
  LocalStorageErrorCode get errorCode;
  @override
  String get message;
}

class LocalStorageObjectMisMatchError implements LocalStorageError {
  LocalStorageObjectMisMatchError({
    required this.message,
    this.errorCode = LocalStorageErrorCode.OBJECT_MISMATCH,
  });

  factory LocalStorageObjectMisMatchError.fromMisMatchType(
    Type expectedType,
    Type actualType,
  ) {
    return LocalStorageObjectMisMatchError(
        message: 'Expected type $expectedType but got $actualType');
  }

  factory LocalStorageObjectMisMatchError.fromMisMatchValue(
    dynamic expectedValue,
    dynamic actualValue,
  ) {
    return LocalStorageObjectMisMatchError(
        message: 'Expected value $expectedValue but got $actualValue');
  }

  @override
  String message;

  @override
  final LocalStorageErrorCode errorCode;
}

class LocalStorageGetKeyError implements LocalStorageError {
  @override
  String message;

  String key;

  @override
  final LocalStorageErrorCode errorCode = LocalStorageErrorCode.STORAGE_ERR;

  LocalStorageGetKeyError(
    this.key,
  ) : message = 'Error getting key $key';
}

class LocalStorageSaveError implements LocalStorageError {
  @override
  String message;

  @override
  final LocalStorageErrorCode errorCode = LocalStorageErrorCode.OBJECT_SAVE;

  LocalStorageSaveError({
    required this.message,
  });

  factory LocalStorageSaveError.fromKey(String key) {
    return LocalStorageSaveError(message: 'Error saving object with key $key');
  }
}

class LocalStorageObjectClearError implements LocalStorageError {
  @override
  String message;

  @override
  final LocalStorageErrorCode errorCode = LocalStorageErrorCode.OBJECT_CLEAR;

  LocalStorageObjectClearError(this.message);

  factory LocalStorageObjectClearError.fromKey(String key) {
    return LocalStorageObjectClearError('Error clearing object with key $key');
  }
}

class LocalStorageClearError implements LocalStorageError {
  @override
  String message;

  @override
  final LocalStorageErrorCode errorCode =
      LocalStorageErrorCode.STORAGE_CLEAR_ERR;

  LocalStorageClearError([this.message = 'Error clearing storage']);
}
