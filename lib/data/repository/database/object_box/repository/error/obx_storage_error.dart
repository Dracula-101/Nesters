import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class ObxStorageError implements AppException {
  @override
  String get message;

  ObxStorageErrorCode get errorCode;
}

enum ObxStorageErrorCode {
  VALUE_GET_ERR,
  VALUE_STREAM_ERR,
  VALUE_SAVE_ERR,
  STORAGE_CLEAR_ERR,
  STORAGE_ERR,
  RESET_ERR;

  String get name => toString().split('.').last;
}

class ObxStorageValueGetError implements ObxStorageError {
  @override
  String message;

  String key;

  ObxStorageValueGetError(this.key)
      : message = 'Error getting value for key: $key';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.VALUE_GET_ERR;
}

class ObxStorageValueStreamError implements ObxStorageError {
  @override
  String message;

  String key;

  ObxStorageValueStreamError(this.key)
      : message = 'Error streaming value for key: $key';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.VALUE_STREAM_ERR;
}

class ObxStorageValueSaveError implements ObxStorageError {
  @override
  String message;

  String key;

  ObxStorageValueSaveError(this.key)
      : message = 'Error saving value for key: $key';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.VALUE_SAVE_ERR;
}

class ObxStorageClearError implements ObxStorageError {
  @override
  String message = 'Error clearing storage';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.STORAGE_CLEAR_ERR;
}

class ObxStorageErrorError implements ObxStorageError {
  @override
  String message = 'Error with storage';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.STORAGE_ERR;
}

class ObxStorageResetError implements ObxStorageError {
  @override
  String message = 'Error resetting storage';

  @override
  final ObxStorageErrorCode errorCode = ObxStorageErrorCode.RESET_ERR;
}
