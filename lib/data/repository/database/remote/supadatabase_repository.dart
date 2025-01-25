import 'dart:developer';

import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaDatabaseRepository extends DatabaseRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> getData(String table,
      {String? orderByColumn, bool? isDescending}) async {
    try {
      // Execute the query to retrieve the first 30 rows from the table
      final response = await _supabaseClient
          .from(table)
          .select()
          .order(orderByColumn ?? 'id', ascending: isDescending ?? true);
      return response;
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> getDataWithId(
    String table,
    String key,
    String value,
  ) async {
    try {
      // Execute the query to retrieve the first 30 rows from the table
      final response =
          await _supabaseClient.from(table).select().eq(key, value);
      // Return the response
      return response;
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getDataWithPagination(
      String table, int offset, int limit,
      {String columns = '', String? removeRowId}) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select(columns);
      if (removeRowId != null) {
        response = response.not('id', 'eq', removeRowId);
      }
      PostgrestTransformBuilder<List<Map<String, dynamic>>> finalResponse =
          response.range(offset, offset + limit);
      return await finalResponse;
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getFilteredData(
      String table, QueryData queryData,
      {String columns = '', String? removeRowId}) {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select(columns);
      if (removeRowId != null) {
        response = response.not('id', 'eq', removeRowId);
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
      return response.order(queryData.fieldName).then((value) => value);
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getMultipleFilteredData(
    String table,
    List<QueryData> queryDataList, {
    String columns = '',
    String? removeRowId,
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> response =
          _supabaseClient.from(table).select(columns);
      if (removeRowId != null) {
        response = response.not('id', 'eq', removeRowId);
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

      return response.then((value) => value);
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<bool> checkExistsData(String table, FieldValue field) async {
    try {
      final response =
          await _supabaseClient.from(table).select().eq(field.key, field.value);
      if (response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryData(
      String table, QueryData queryData) {
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
  Future<void> setData(String table, SetData setData) {
    try {
      // Execute the insert query using the Supabase client
      return _supabaseClient.from(table).insert(setData.toMap());
    } catch (error) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to set data: $error');
    }
  }

  @override
  Future<void> updateData(String table, UpdateData newData) async {
    try {
      // Execute the update query using the Supabase client
      await _supabaseClient
          .from(table)
          .update(
            newData.toMap(),
          )
          .eq(newData.columnId, newData.columnValue);
    } catch (error) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to update data: $error');
    }
  }

  @override
  Future<void> deleteData(String table, DeleteData deleteData) {
    try {
      // Execute the delete query using the Supabase client
      return _supabaseClient
          .from(table)
          .delete()
          .eq(deleteData.fieldName, deleteData.value);
    } catch (error) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to delete data: $error');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> searchData(
      String table, String field, String value) {
    try {
      // Execute the query to retrieve the first 30 rows from the table
      return _supabaseClient
          .from(table)
          .select()
          .like(
            field,
            '%$value%',
          )
          .order(field)
          .asStream();
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchDataFromFuture(
      String table, String field, String value) async {
    try {
      // Execute the query to retrieve the first 30 rows from the table
      return await _supabaseClient.from(table).select().like(
            field,
            '%$value%',
          );
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }
}
