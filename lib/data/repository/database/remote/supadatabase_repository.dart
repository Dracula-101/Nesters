import 'dart:developer';
import 'dart:io';

import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:nesters/data/repository/database/remote/error/database_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaDatabaseRepository extends DatabaseRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> getData(
    String table, {
    bool? isDescending,
    List<DbKey> columns = const [],
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select();
      if (columns.isNotEmpty) {
        response.select(columns.map((e) => e.key).toList().join(','));
      }
      if (orderBy != null) {
        for (var order in orderBy) {
          response.order(order.key, ascending: !order.isDescending);
        }
      }
      if (whereFields != null) {
        for (var field in whereFields) {
          response = response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response = response.neq(field.key, field.value);
        }
      }
      return response.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.GET_DATA_ERR, table);
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> getDataWithId(
    String table,
    FieldValue field, {
    List<DbKey> columns = const [],
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select();
      response = response.eq(field.key, field.value);
      if (whereFields != null) {
        for (var field in whereFields) {
          response = response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response = response.neq(field.key, field.value);
        }
      }
      return await response;
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.GET_DATA_ERR, table);
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getDataWithPagination(
    String table,
    int offset,
    int limit, {
    List<DbKey> columns = const [],
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient
              .from(table)
              .select(columns.map((e) => e.key).toList().join(','));
      if (whereFields != null) {
        for (var field in whereFields) {
          response = response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response = response.neq(field.key, field.value);
        }
      }
      PostgrestTransformBuilder transformBuilder =
          response.limit(limit).range(offset, offset + limit);
      if (orderBy != null) {
        for (var order in orderBy) {
          transformBuilder =
              transformBuilder.order(order.key, ascending: !order.isDescending);
        }
      }
      return transformBuilder.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.GET_DATA_ERR, table);
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getFilteredData(
    String table,
    QueryData queryData, {
    List<DbKey> columns = const [],
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient
              .from(table)
              .select(columns.map((e) => e.key).toList().join(','));
      if (queryData.equalTo != null) {
        response =
            response.eq(queryData.equalTo!.key, queryData.equalTo!.value);
      }

      if (queryData.greaterThan != null) {
        response = response.gt(
            queryData.greaterThan!.key, queryData.greaterThan!.value);
      }

      if (queryData.greaterThanOrEqualTo != null) {
        response = response.gte(queryData.greaterThanOrEqualTo!.key,
            queryData.greaterThanOrEqualTo!.value);
      }

      if (queryData.lessThan != null) {
        response =
            response.lt(queryData.lessThan!.key, queryData.lessThan!.value);
      }

      if (queryData.lessThanOrEqualTo != null) {
        response = response.lte(queryData.lessThanOrEqualTo!.key,
            queryData.lessThanOrEqualTo!.value);
      }
      if (whereFields != null) {
        for (var field in whereFields) {
          response = response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response = response.neq(field.key, field.value);
        }
      }
      PostgrestTransformBuilder transformBuilder = response;
      if (orderBy != null) {
        for (var order in orderBy) {
          transformBuilder =
              transformBuilder.order(order.key, ascending: !order.isDescending);
        }
      }
      return transformBuilder.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.GET_DATA_ERR, table);
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getMultipleFilteredData(
    String table,
    List<QueryData> queryDataList, {
    List<DbKey> columns = const [],
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient
              .from(table)
              .select(columns.map((e) => e.key).toList().join(','));
      for (var queryData in queryDataList) {
        log("QueryData: ${queryData.toMap()}");
        if (queryData.equalTo != null) {
          response =
              response.eq(queryData.equalTo!.key, queryData.equalTo!.value);
        }
        if (queryData.greaterThan != null) {
          response = response.gt(
              queryData.greaterThan!.key, queryData.greaterThan!.value);
        }

        if (queryData.greaterThanOrEqualTo != null) {
          response = response.gte(queryData.greaterThanOrEqualTo!.key,
              queryData.greaterThanOrEqualTo!.value);
        }

        if (queryData.lessThan != null) {
          response =
              response.lt(queryData.lessThan!.key, queryData.lessThan!.value);
        }

        if (queryData.lessThanOrEqualTo != null) {
          response = response.lte(queryData.lessThanOrEqualTo!.key,
              queryData.lessThanOrEqualTo!.value);
        }
      }
      if (whereFields != null) {
        for (var field in whereFields) {
          response = response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response = response.neq(field.key, field.value);
        }
      }
      PostgrestTransformBuilder transformBuilder = response;
      if (orderBy != null) {
        for (var order in orderBy) {
          transformBuilder =
              transformBuilder.order(order.key, ascending: !order.isDescending);
        }
      }
      return transformBuilder.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.GET_DATA_ERR, table);
    }
  }

  @override
  Future<bool> checkExistsData(String table, List<FieldValue> fields) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select();
      for (var field in fields) {
        response = response.eq(field.key, field.value);
      }
      final List<Map<String, dynamic>> data = await response;
      return data.isNotEmpty;
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.CHECK_DATA_ERR, table);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryData(
    String table,
    QueryData queryData, {
    List<DbKey> columns = const [],
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> queryBuilder =
          _supabaseClient.from(table).select();
      if (queryData.equalTo != null) {
        queryBuilder =
            queryBuilder.eq(queryData.equalTo!.key, queryData.equalTo!.value);
      }

      if (queryData.greaterThan != null) {
        queryBuilder = queryBuilder.gt(
            queryData.greaterThan!.key, queryData.greaterThan!.value);
      }

      if (queryData.greaterThanOrEqualTo != null) {
        queryBuilder = queryBuilder.gte(queryData.greaterThanOrEqualTo!.key,
            queryData.greaterThanOrEqualTo!.value);
      }

      if (queryData.lessThan != null) {
        queryBuilder =
            queryBuilder.lt(queryData.lessThan!.key, queryData.lessThan!.value);
      }

      if (queryData.lessThanOrEqualTo != null) {
        queryBuilder = queryBuilder.lte(queryData.lessThanOrEqualTo!.key,
            queryData.lessThanOrEqualTo!.value);
      }
      return queryBuilder.order(queryData.fieldName).then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.QUERY_DATA_ERR, table);
    }
  }

  @override
  Future<void> setData(
    String table,
    SetData setData, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) {
    try {
      final PostgrestFilterBuilder response =
          _supabaseClient.from(table).upsert(setData.toMap());
      if (whereFields != null) {
        for (var field in whereFields) {
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.neq(field.key, field.value);
        }
      }
      return response.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.SET_DATA_ERR, table);
    }
  }

  @override
  Future<void> updateData(
    String table,
    UpdateData newData, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) async {
    try {
      final PostgrestFilterBuilder response = _supabaseClient
          .from(table)
          .update(
            newData.toMap(),
          )
          .eq(
            newData.columnId,
            newData.columnValue,
          );
      if (whereFields != null) {
        for (var field in whereFields) {
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.neq(field.key, field.value);
        }
      }
      return response.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.UPDATE_DATA_ERR, table);
    }
  }

  @override
  Future<void> deleteData(
    String table,
    DeleteData deleteData, {
    List<FieldValue>? whereNotFields,
  }) {
    try {
      final PostgrestFilterBuilder response =
          _supabaseClient.from(table).delete();
      response.eq(deleteData.fieldName, deleteData.value);
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.neq(field.key, field.value);
        }
      }
      return response.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.DELETE_DATA_ERR, table);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> searchData(
    String table,
    FieldValue field, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) {
    try {
      final PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select();
      response.like(
        field.key,
        '%${field.value}%',
      );
      if (whereFields != null) {
        for (var field in whereFields) {
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.neq(field.key, field.value);
        }
      }
      return response.asStream();
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.SEARCH_DATA_ERR, table);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchDataFromFuture(
    String table,
    FieldValue field, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  }) async {
    try {
      final PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select();
      response.like(
        field.key,
        '%${field.value}%',
      );
      if (whereFields != null) {
        for (var field in whereFields) {
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.neq(field.key, field.value);
        }
      }
      return response.then((value) => value);
    } on SocketException {
      throw NoNetworkError();
    } on PostgrestException catch (e) {
      throw DatabaseErrorFactory.fromCode(
          DatabaseErrorCode.SEARCH_DATA_ERR, table);
    }
  }
}
