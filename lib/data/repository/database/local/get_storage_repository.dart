import 'package:get_storage/get_storage.dart';

import 'error/local_storage_error.dart';
import 'local_storage_repository.dart';

class GetStorageRepository extends LocalStorageRepository {
  final GetStorage _getStorage = GetStorage();

  @override
  Future<void> init() async {
    await _getStorage.initStorage;
  }

  @override
  Future<void> clear() async {
    await _getStorage.erase();
  }

  @override
  Future<Object> getObject(String key) async {
    try {
      final value = _getStorage.read(key);
      if (value is! Object) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            double, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveObject(String key, Object value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  String? getString(String key) {
    try {
      final value = _getStorage.read(key);
      if (value is! String?) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            String, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveString(String key, String value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  bool? getBool(String key) {
    try {
      final value = _getStorage.read(key);
      if (value is! bool?) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            bool, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  int? getInt(String key) {
    try {
      final value = _getStorage.read(key);
      if (value is! int?) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            int, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveInt(String key, int value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  double? getDouble(String key)  {
    try {
      final value = _getStorage.read(key);
      if (value is! double) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            double, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  List<Object?>? getListObject(String key) {
    try {
      final value = _getStorage.read(key);
      if (value is! List<Object>) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            List<Object>, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<Object?, Object?>? getMapObject(String key) {
    try {
      final value = _getStorage.read(key);
      if (value is! Map<Object?, Object?>?) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            Map<Object?, Object?>, value.runtimeType);
      }
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveMapObject(String key, Map<Object, Object> value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  T? getClass<T>(
      String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final value = _getStorage.read(key);
      if (value is! Map<String, dynamic>) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            Map<String, dynamic>, value.runtimeType);
      }
      return fromJson(value);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveClass<T>(
      String key, T value, Map<String, dynamic> Function(T) toJson) async {
    try {
      await _getStorage.write(key, toJson(value));
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  List<T?>? getListClass<T>(
      String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final value = _getStorage.read(key);
      if (value is! List<Map<String, dynamic>>) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            List<Map<String, dynamic>>, value.runtimeType);
      }
      return value.map((e) => fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveListClass<T>(String key, List<T> value,
      Map<String, dynamic> Function(T) toJson) async {
    try {
      await _getStorage.write(key, value.map((e) => toJson(e)).toList());
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<void> saveListObject(String key, List<Object> value) async {
    try {
      await _getStorage.write(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }
}
