// ignore_for_file: constant_identifier_names

enum FirestoreErrorCode {
  ABORTED,
  ALREADY_EXISTS,
  CANCELLED,
  DATA_LOSS,
  DEADLINE_EXCEEDED,
  FAILED_PRECONDITION,
  INTERNAL,
  INVALID_ARGUMENT,
  NOT_FOUND,
  OK,
  OUT_OF_RANGE,
  PERMISSION_DENIED,
  RESOURCE_EXHAUSTED,
  UNAUTHENTICATED,
  UNAVAILABLE,
  UNIMPLEMENTED,
  UNKNOWN,
}

class FirestoreError implements Exception {
  final FirestoreErrorCode code;
  final String message;

  FirestoreError(this.code, this.message);

  factory FirestoreError.fromCode(String code) {
    FirestoreErrorCode errorCode = FirestoreErrorCode.values.firstWhere(
      (element) =>
          code.toLowerCase() ==
          element.toString().toLowerCase().split('.').last,
      orElse: () => FirestoreErrorCode.UNKNOWN,
    );
    String message = codeToMessage(errorCode);
    return FirestoreError(errorCode, message);
  }

  // code to user friendly message
  static String codeToMessage(FirestoreErrorCode code) {
    switch (code) {
      case FirestoreErrorCode.ABORTED:
        return 'The operation was aborted due to a concurrency issue like transaction aborts.';
      case FirestoreErrorCode.ALREADY_EXISTS:
        return 'Document already exists.';
      case FirestoreErrorCode.CANCELLED:
        return 'The operation was cancelled.';
      case FirestoreErrorCode.DATA_LOSS:
        return 'Unrecoverable data loss or corruption.';
      case FirestoreErrorCode.DEADLINE_EXCEEDED:
        return 'Deadline expired before operation could complete.';
      case FirestoreErrorCode.FAILED_PRECONDITION:
        return 'Operation was rejected due to incorrect state.';
      case FirestoreErrorCode.INTERNAL:
        return 'Internal errors.';
      case FirestoreErrorCode.INVALID_ARGUMENT:
        return 'Client specified an invalid argument.';
      case FirestoreErrorCode.NOT_FOUND:
        return 'Document not found.';
      case FirestoreErrorCode.OK:
        return 'The operation completed successfully.';
      case FirestoreErrorCode.OUT_OF_RANGE:
        return 'Operation was attempted past the valid range.';
      case FirestoreErrorCode.PERMISSION_DENIED:
        return 'The caller does not have permission to execute the specified operation.';
      case FirestoreErrorCode.RESOURCE_EXHAUSTED:
        return 'Quota exceeded.';
      case FirestoreErrorCode.UNAUTHENTICATED:
        return 'The request does not have valid authentication credentials.';
      case FirestoreErrorCode.UNAVAILABLE:
        return 'The service is currently unavailable.';
      case FirestoreErrorCode.UNIMPLEMENTED:
        return 'Operation is not implemented or not supported/enabled.';
      case FirestoreErrorCode.UNKNOWN:
        return 'Unknown error.';
    }
  }
}

// ABORTED	
// The operation was aborted, typically due to a concurrency issue like transaction aborts, etc.

// ALREADY_EXISTS	
// Some document that we attempted to create already exists.

// CANCELLED	
// The operation was cancelled (typically by the caller).

// DATA_LOSS	
// Unrecoverable data loss or corruption.

// DEADLINE_EXCEEDED	
// Deadline expired before operation could complete.

// FAILED_PRECONDITION	
// Operation was rejected because the system is not in a state required for the operation's execution.

// INTERNAL	
// Internal errors.

// INVALID_ARGUMENT	
// Client specified an invalid argument.

// NOT_FOUND	
// Some requested document was not found.

// OK	
// The operation completed successfully.

// OUT_OF_RANGE	
// Operation was attempted past the valid range.

// PERMISSION_DENIED	
// The caller does not have permission to execute the specified operation.

// RESOURCE_EXHAUSTED	
// Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file system is out of space.

// UNAUTHENTICATED	
// The request does not have valid authentication credentials for the operation.

// UNAVAILABLE	
// The service is currently unavailable.

// UNIMPLEMENTED	
// Operation is not implemented or not supported/enabled.

// UNKNOWN	
// Unknown error or an error from a different error domain.