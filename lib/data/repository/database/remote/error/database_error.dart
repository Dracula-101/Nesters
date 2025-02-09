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
  GET_DATA_ERROR,
  CHECK_DATA_ERROR,
  ADD_DATA_ERROR,
  SET_DATA_ERROR,
  QUERY_DATA_ERROR,
  UPDATE_DATA_ERROR,
  SEARCH_DATA_ERROR,
  DELETE_DATA_ERROR;

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
          code: DatabaseErrorCode.GET_DATA_ERROR,
          message: 'Error getting data from $table',
        );
}

class DatabaseCheckDataError extends DatabaseError {
  String table;

  DatabaseCheckDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.CHECK_DATA_ERROR,
          message: 'Error checking data in $table',
        );
}

class DatabaseAddDataError extends DatabaseError {
  String table;

  DatabaseAddDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.ADD_DATA_ERROR,
          message: 'Error adding data to $table',
        );
}

class DatabaseSetDataError extends DatabaseError {
  String table;

  DatabaseSetDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.SET_DATA_ERROR,
          message: 'Error setting data to $table',
        );
}

class DatabaseQueryDataError extends DatabaseError {
  String table;

  DatabaseQueryDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.QUERY_DATA_ERROR,
          message: 'Error querying data in $table',
        );
}

class DatabaseSearchDataError extends DatabaseError {
  String table;

  DatabaseSearchDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.SEARCH_DATA_ERROR,
          message: 'Error searching data in $table',
        );
}

class DatabaseUpdateDataError extends DatabaseError {
  String table;

  DatabaseUpdateDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.UPDATE_DATA_ERROR,
          message: 'Error updating data in $table',
        );
}

class DatabaseDeleteDataError extends DatabaseError {
  String table;

  DatabaseDeleteDataError({
    required this.table,
  }) : super(
          code: DatabaseErrorCode.DELETE_DATA_ERROR,
          message: 'Error deleting data from $table',
        );
}

class DatabaseErrorFactory {
  static DatabaseError fromCode(DatabaseErrorCode code, String table) {
    switch (code) {
      case DatabaseErrorCode.GET_DATA_ERROR:
        return DatabaseGetDataError(table: table);
      case DatabaseErrorCode.CHECK_DATA_ERROR:
        return DatabaseCheckDataError(table: table);
      case DatabaseErrorCode.ADD_DATA_ERROR:
        return DatabaseAddDataError(table: table);
      case DatabaseErrorCode.SET_DATA_ERROR:
        return DatabaseSetDataError(table: table);
      case DatabaseErrorCode.QUERY_DATA_ERROR:
        return DatabaseQueryDataError(table: table);
      case DatabaseErrorCode.SEARCH_DATA_ERROR:
        return DatabaseSearchDataError(table: table);
      case DatabaseErrorCode.UPDATE_DATA_ERROR:
        return DatabaseUpdateDataError(table: table);
      case DatabaseErrorCode.DELETE_DATA_ERROR:
        return DatabaseDeleteDataError(table: table);
    }
  }
}
