// ignore_for_file: constant_identifier_names

import 'package:nesters/data/repository/utils/app_exception.dart';

abstract class DatabaseError extends AppException {
  DatabaseErrorCode code;

  @override
  String message;

  DatabaseError({
    required this.code,
    required this.message,
  });
}

enum DatabaseErrorCode {
  GET_DATA_ERR,
  CHECK_DATA_ERR,
  ADD_DATA_ERR,
  SET_DATA_ERR,
  QUERY_DATA_ERR,
  UPDATE_DATA_ERR,
  SEARCH_DATA_ERR,
  DELETE_DATA_ERR;

  @override
  String toString() {
    return toString().split('.').last;
  }
}

class DatabaseGetDataError extends DatabaseError {
  String table;

  DatabaseGetDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.GET_DATA_ERR,
          message: 'Error getting data from $table',
        );
}

class DatabaseCheckDataError extends DatabaseError {
  String table;

  DatabaseCheckDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.CHECK_DATA_ERR,
          message: 'Error checking data in $table',
        );
}

class DatabaseAddDataError extends DatabaseError {
  String table;

  DatabaseAddDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.ADD_DATA_ERR,
          message: 'Error adding data to $table',
        );
}

class DatabaseSetDataError extends DatabaseError {
  String table;

  DatabaseSetDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.SET_DATA_ERR,
          message: 'Error setting data to $table',
        );
}

class DatabaseQueryDataError extends DatabaseError {
  String table;

  DatabaseQueryDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.QUERY_DATA_ERR,
          message: 'Error querying data in $table',
        );
}

class DatabaseSearchDataError extends DatabaseError {
  String table;

  DatabaseSearchDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.SEARCH_DATA_ERR,
          message: 'Error searching data in $table',
        );
}

class DatabaseUpdateDataError extends DatabaseError {
  String table;

  DatabaseUpdateDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.UPDATE_DATA_ERR,
          message: 'Error updating data in $table',
        );
}

class DatabaseDeleteDataError extends DatabaseError {
  String table;

  DatabaseDeleteDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.DELETE_DATA_ERR,
          message: 'Error deleting data from $table',
        );
}

class DatabaseErrorFactory {
  static DatabaseError fromCode(DatabaseErrorCode code, String table) {
    switch (code) {
      case DatabaseErrorCode.GET_DATA_ERR:
        return DatabaseGetDataError(table: table);
      case DatabaseErrorCode.CHECK_DATA_ERR:
        return DatabaseCheckDataError(table: table);
      case DatabaseErrorCode.ADD_DATA_ERR:
        return DatabaseAddDataError(table: table);
      case DatabaseErrorCode.SET_DATA_ERR:
        return DatabaseSetDataError(table: table);
      case DatabaseErrorCode.QUERY_DATA_ERR:
        return DatabaseQueryDataError(table: table);
      case DatabaseErrorCode.SEARCH_DATA_ERR:
        return DatabaseSearchDataError(table: table);
      case DatabaseErrorCode.UPDATE_DATA_ERR:
        return DatabaseUpdateDataError(table: table);
      case DatabaseErrorCode.DELETE_DATA_ERR:
        return DatabaseDeleteDataError(table: table);
    }
  }
}

class NoNetworkError extends AppException {
  @override
  String message;

  NoNetworkError([
    this.message = 'Please check your internet connection and try again',
  ]);
}
