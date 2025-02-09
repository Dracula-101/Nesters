import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class ObxStorageError implements AppException {
  @override
  String get message;

  ObxStorageErrorCode get errorCode;
}

enum ObxStorageErrorCode {
  VALUE_GET_ERROR,
  VALUE_STREAM_ERROR,
  VALUE_SAVE_ERROR,
  STORAGE_CLEAR_ERROR,
  STORAGE_ERROR,
  RESET_ERROR;

  String get name => toString().split('.').last;
}

class ObxStorageValueGetError implements ObxStorageError {
  @override
  String message;

  String key;

  ObxStorageValueGetError(this.key)
      : message = 'Error getting value for key: $key';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.VALUE_GET_ERROR;
}

class ObxStorageValueStreamError implements ObxStorageError {
  @override
  String message;

  String key;

  ObxStorageValueStreamError(this.key)
      : message = 'Error streaming value for key: $key';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.VALUE_STREAM_ERROR;
}

class ObxStorageValueSaveError implements ObxStorageError {
  @override
  String message;

  String key;

  ObxStorageValueSaveError(this.key)
      : message = 'Error saving value for key: $key';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.VALUE_SAVE_ERROR;
}

class ObxStorageClearError implements ObxStorageError {
  @override
  String message = 'Error clearing storage';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.STORAGE_CLEAR_ERROR;
}

class ObxStorageErrorError implements ObxStorageError {
  @override
  String message = 'Error with storage';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.STORAGE_ERROR;
}

class ObxStorageResetError implements ObxStorageError {
  @override
  String message = 'Error resetting storage';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.RESET_ERROR;
}
