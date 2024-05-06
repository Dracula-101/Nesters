abstract class LocalStorageRepository {
  // ================= Intialize =================
  Future<void> init();

  // ================= Object =================
  Future<Object?> getObject(String key);
  Future<void> saveObject(String key, Object value);

  // ================= String =================
  Future<String?> getString(String key);
  Future<void> saveString(String key, String value);

  // ================= Int =================
  Future<int?> getInt(String key);
  Future<void> saveInt(String key, int value);

  // ================= Double =================
  Future<double?> getDouble(String key);
  Future<void> saveDouble(String key, double value);

  // ================= List<Object> =================
  Future<List<Object?>?> getListObject(String key);
  Future<void> saveListObject(String key, List<Object> value);

  // ================= Map<Object, Object> =================
  Future<Map<Object?, Object?>?> getMapObject(String key);
  Future<void> saveMapObject(String key, Map<Object, Object> value);

  // ================= Custom Classes =================
  Future<T?> getClass<T>(String key, T Function(Map<String, dynamic>) fromJson);
  Future<void> saveClass<T>(
      String key, T value, Map<String, dynamic> Function(T) toJson);

  // ================= List of Custom Classes =================
  Future<List<T?>?> getListClass<T>(
      String key, T Function(Map<String, dynamic>) fromJson);
  Future<void> saveListClass<T>(
      String key, List<T> value, Map<String, dynamic> Function(T) toJson);

  // ================= Clear =================
  Future<void> clear();
}
