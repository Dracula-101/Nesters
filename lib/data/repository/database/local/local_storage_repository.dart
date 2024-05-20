abstract class LocalStorageRepository {
  // ================= Intialize =================
  Future<void> init();

  // ================= Object =================
  Object? getObject(String key);
  Future<void> saveObject(String key, Object value);

  // ================= String =================
  String? getString(String key);
  Future<void> saveString(String key, String value);

  // ================= Bool =================
  bool? getBool(String key);
  Future<void> saveBool(String key, bool value);

  // ================= Int =================
  int? getInt(String key);
  Future<void> saveInt(String key, int value);

  // ================= Double =================
  double? getDouble(String key);
  Future<void> saveDouble(String key, double value);

  // ================= List<Object> =================
  List<Object?>? getListObject(String key);
  Future<void> saveListObject(String key, List<Object> value);

  // ================= Map<Object, Object> =================
  Map<Object?, Object?>? getMapObject(String key);
  Future<void> saveMapObject(String key, Map<Object, Object> value);

  // ================= Custom Classes =================
  T? getClass<T>(String key, T Function(Map<String, dynamic>) fromJson);
  Future<void> saveClass<T>(
      String key, T value, Map<String, dynamic> Function(T) toJson);

  // ================= List of Custom Classes =================
  List<T?>? getListClass<T>(
      String key, T Function(Map<String, dynamic>) fromJson);
  Future<void> saveListClass<T>(
      String key, List<T> value, Map<String, dynamic> Function(T) toJson);

  // ================= Clear =================
  Future<void> clear();
}

class LocalStorageKeys {
  static const userOnboardingComplete = 'userOnboardingComplete';
  static const userToken = 'userToken';
  static const userDataSaved = 'userDataSaved';
  static const lastSavedRecipientUsers = 'lastSavedRecipientUsers';
}
