import 'dart:developer';

import 'package:nesters/data/repository/database/remote/database_repository.dart';
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
      final PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
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
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
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
      final PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select();
      if (columns.isNotEmpty) {
        response.select(columns.map((e) => e.key).toList().join(','));
      }
      if (orderBy != null) {
        for (var order in orderBy) {
          response.order(order.key, ascending: !order.isDescending);
        }
      }
      response.eq(field.key, field.value);
      if (whereFields != null) {
        for (var field in whereFields) {
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.not(field.key, 'eq', field.value);
        }
      }
      return await response;
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
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
          _supabaseClient.from(table).select();
      if (columns.isNotEmpty) {
        response.select(columns.map((e) => e.key).toList().join(','));
      }
      if (orderBy != null) {
        for (var order in orderBy) {
          response.order(order.key, ascending: !order.isDescending);
        }
      }
      response.range(offset, limit);
      if (whereFields != null) {
        for (var field in whereFields) {
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
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
          _supabaseClient.from(table).select();
      if (columns.isNotEmpty) {
        response.select(columns.map((e) => e.key).toList().join(','));
      }
      if (orderBy != null) {
        for (var order in orderBy) {
          response.order(order.key, ascending: !order.isDescending);
        }
      }
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
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.order(queryData.fieldName).then((value) => value);
    } catch (e) {
      throw Exception('Failed to get data: $e');
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
          _supabaseClient.from(table).select();
      if (columns.isNotEmpty) {
        response.select(columns.map((e) => e.key).toList().join(','));
      }
      if (orderBy != null) {
        for (var order in orderBy) {
          response.order(order.key, ascending: !order.isDescending);
        }
      }
      for (var queryData in queryDataList) {
        if (queryData.equalTo != null) {
          log("Key: ${queryData.equalTo!.key} Value: ${queryData.equalTo!.value}");
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
          response.eq(field.key, field.value);
        }
      }
      if (whereNotFields != null) {
        for (var field in whereNotFields) {
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (e) {
      throw Exception('Failed to get data: $e');
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
    } catch (e) {
      throw Exception('Failed to get data: $e');
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
    } catch (e) {
      throw Exception(e.toString());
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
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (error) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to set data: $error');
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
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (error) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to update data: $error');
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
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (error) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to delete data: $error');
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
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.asStream();
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
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
          response.not(field.key, 'eq', field.value);
        }
      }
      return response.then((value) => value);
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }
}
