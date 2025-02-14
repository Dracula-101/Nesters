abstract class DatabaseRepository {
  Future<List<Map<String, dynamic>>> getData(
    String table, {
    bool? isDescending,
    List<DbKey> columns,
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<List<Map<String, dynamic>>?> getDataWithId(
    String table,
    FieldValue field, {
    List<DbKey> columns,
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<List<Map<String, dynamic>?>> getDataWithPagination(
    String table,
    int offset,
    int limit, {
    List<DbKey> columns,
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<List<Map<String, dynamic>?>> getFilteredData(
    String table,
    QueryData queryData, {
    List<DbKey> columns,
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<List<Map<String, dynamic>?>> getMultipleFilteredData(
    String table,
    List<QueryData> queryDataList, {
    List<DbKey> columns,
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<bool> checkExistsData(
    String table,
    List<FieldValue> fields,
  );

  Future<void> setData(
    String table,
    SetData setData, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<List<Map<String, dynamic>>> queryData(
    String table,
    QueryData queryData, {
    List<DbKey> columns,
    List<OrderByKey>? orderBy,
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<void> updateData(
    String table,
    UpdateData newData, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<void> deleteData(
    String table,
    DeleteData deleteData, {
    List<FieldValue>? whereNotFields,
  });

  Stream<List<Map<String, dynamic>>> searchData(
    String table,
    FieldValue field, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });

  Future<List<Map<String, dynamic>>> searchDataFromFuture(
    String table,
    FieldValue field, {
    List<FieldValue>? whereFields,
    List<FieldValue>? whereNotFields,
  });
}

class DbKey {
  final String key;

  DbKey({
    required this.key,
  });
}

class OrderByKey {
  final String key;
  final bool isDescending;

  OrderByKey({
    required this.key,
    required this.isDescending,
  });
}

class FieldValue {
  final String key;
  final dynamic value;

  FieldValue({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      key: value,
    };
  }

  @override
  String toString() {
    return 'key: $key, value: $value';
  }
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

  Map<String, dynamic> toMap() {
    return {
      fieldName: {
        'equalTo': equalTo,
        'notEqualTo': notEqualTo,
        'lessThan': lessThan,
        'greaterThan': greaterThan,
        'lessThanOrEqualTo': lessThanOrEqualTo,
        'greaterThanOrEqualTo': greaterThanOrEqualTo,
      },
    };
  }
}

class UpdateFieldValue {
  final String fieldName;
  final dynamic newValue;

  UpdateFieldValue({
    required this.fieldName,
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
  final String columnId;
  final String columnValue;
  final List<FieldValue> fields;

  UpdateData({
    required this.columnId,
    required this.columnValue,
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
