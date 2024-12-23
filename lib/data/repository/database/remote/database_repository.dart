abstract class DatabaseRepository {
  Future<Map<String, dynamic>?> getData(String table);
  Future<Map<String, dynamic>?> getDataWithId(String table, String id);
  Future<List<Map<String, dynamic>?>> getDataWithPagination(
      String table, int offset, int limit,
      {String columns = '', String? removeRowId});
  Future<List<Map<String, dynamic>?>> getFilteredData(
      String table, QueryData queryData,
      {String columns = '', String? removeRowId});
  Future<bool> checkExistsData(String table, FieldValue field);
  Future<void> setData(String table, SetData setData);
  Future<List<Map<String, dynamic>>> queryData(
      String table, QueryData queryData);
  Future<void> updateData(String table, UpdateData newData);
  Future<void> deleteData(String table, DeleteData deleteData);
  Stream<List<Map<String, dynamic>>> searchData(
      String table, String field, String value);
  Future<List<Map<String, dynamic>>> searchDataFromFuture(
      String table, String field, String value);
}

class FieldValue {
  final String key;
  final dynamic value;

  FieldValue({
    required this.key,
    required this.value,
  });
}

class SetData {
  final List<FieldValue> fields;

  SetData({
    required this.fields,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    for (var element in fields) {
      map[element.key] = element.value;
    }
    return map;
  }
}

class QueryData {
  final String fieldName;
  final dynamic equalTo;
  final dynamic notEqualTo;
  final dynamic lessThan;
  final dynamic greaterThan;
  final dynamic lessThanOrEqualTo;
  final dynamic greaterThanOrEqualTo;

  QueryData({
    required this.fieldName,
    this.equalTo,
    this.notEqualTo,
    this.lessThan,
    this.greaterThan,
    this.lessThanOrEqualTo,
    this.greaterThanOrEqualTo,
  });
}

class UpdateFieldValue {
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;

  UpdateFieldValue({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
  });
  //getter
  Map<String, dynamic> toMap() {
    return {
      fieldName: newValue,
    };
  }
}

class UpdateData {
  final List<UpdateFieldValue> fields;

  UpdateData({
    required this.fields,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    for (var element in fields) {
      map[element.fieldName] = element.newValue;
    }
    return map;
  }
}

class DeleteData {
  final String fieldName;
  final dynamic value;

  DeleteData({
    required this.fieldName,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      fieldName: value,
    };
  }
}
