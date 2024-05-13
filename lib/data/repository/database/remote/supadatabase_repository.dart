import 'package:nesters/data/repository/database/remote/database_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaDatabaseRepository extends DatabaseRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> getData(String table) async {
    try {
      // Execute the query to retrieve the first 30 rows from the table
      final response = await _supabaseClient.from(table).select();

      // Return the response
      return {'data': response};
    } catch (e) {
      // Throw an exception with a descriptive error message
      throw Exception('Failed to get data: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getDataWithPagination(
      String table, int offset, int limit) async {
    try {
      print('Getting user quick profiles with limit $limit and offset $offset');
      final response = await _supabaseClient
          .from(table)
          .select('''id, full_name, profile_image, selected_college_name, selected_course_name, city, state, work_experience''').range(
              offset, offset + limit);

      return response;
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
      final List<UpdateFieldValue> updateFields = newData.fields;
      for (var field in updateFields) {
        await _supabaseClient
            .from(table)
            .update({field.fieldName: field.newValue}).match(
                {field.fieldName: field.oldValue});
      }
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
