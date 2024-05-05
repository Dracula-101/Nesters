class LocalStorageObjectMisMatchError implements Exception {
  final String message;

  LocalStorageObjectMisMatchError(this.message);

  @override
  String toString() {
    return 'ObjectMisMatchError: $message';
  }

  factory LocalStorageObjectMisMatchError.fromMisMatchType(
      Type expectedType, Type actualType) {
    return LocalStorageObjectMisMatchError(
        'Expected type $expectedType but got $actualType');
  }

  factory LocalStorageObjectMisMatchError.fromMisMatchValue(
      dynamic expectedValue, dynamic actualValue) {
    return LocalStorageObjectMisMatchError(
        'Expected value $expectedValue but got $actualValue');
  }
}

class LocalStorageSaveError implements Exception {
  final String message;

  LocalStorageSaveError(this.message);

  @override
  String toString() {
    return 'ObjectSaveError: $message';
  }

  factory LocalStorageSaveError.fromKey(String key) {
    return LocalStorageSaveError('Error saving object with key $key');
  }
}

class ObjectClearError implements Exception {
  final String message;

  ObjectClearError(this.message);

  @override
  String toString() {
    return 'ObjectClearError: $message';
  }

  factory ObjectClearError.fromKey(String key) {
    return ObjectClearError('Error clearing object with key $key');
  }
}
