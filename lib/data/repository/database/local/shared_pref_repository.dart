import 'dart:convert';

import 'package:nesters/data/repository/database/local/local_storage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error/local_storage_error.dart';

class SharedPrefRepository extends LocalStorageRepository {
  late final SharedPreferences _sharedPreferences;

  @override
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  @override
  Future<Object> getObject(String key) async {
    try {
      final value = _sharedPreferences.get(key);
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
      await _sharedPreferences.setString(key, value.toString());
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      final value = _sharedPreferences.getString(key);
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveString(String key, String value) async {
    try {
      await _sharedPreferences.setString(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      final value = _sharedPreferences.getInt(key);
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveInt(String key, int value) async {
    try {
      await _sharedPreferences.setInt(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      final value = _sharedPreferences.getBool(key);
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      await _sharedPreferences.setBool(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      final value = _sharedPreferences.getDouble(key);
      return value;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    try {
      await _sharedPreferences.setDouble(key, value);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<List<Object?>?> getListObject(String key) async {
    try {
      final value = _sharedPreferences.getStringList(key);
      final decodedValue = value?.map((e) => jsonDecode(e)).toList();
      if (decodedValue is! List<Object?>) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            List<Object?>, decodedValue.runtimeType);
      }
      return decodedValue;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveListObject(String key, List<Object> value) async {
    try {
      List<String> jsonEncodedList = value.map((e) => jsonEncode(e)).toList();
      await _sharedPreferences.setStringList(key, jsonEncodedList);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<Map<Object?, Object?>?> getMapObject(String key) async {
    try {
      final value = _sharedPreferences.getString(key);
      final decodedValue = jsonDecode(value!);
      if (decodedValue is! Map<Object?, Object?>) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            Map<Object?, Object?>, decodedValue.runtimeType);
      }
      return decodedValue;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveMapObject(String key, Map<Object, Object> value) async {
    try {
      final jsonEncodedMap = jsonEncode(value);
      await _sharedPreferences.setString(key, jsonEncodedMap);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<T?> getClass<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final value = _sharedPreferences.getString(key);
      if (value == null) {
        return null;
      }
      final decodedValue = fromJson(jsonDecode(value));
      return decodedValue;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveClass<T>(
      String key, T value, Map<String, dynamic> Function(T) toJson) async {
    try {
      final jsonEncodedValue = jsonEncode(toJson(value));
      await _sharedPreferences.setString(key, jsonEncodedValue);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }

  @override
  Future<List<T?>?> getListClass<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final value = _sharedPreferences.getStringList(key);
      final decodedValue = value?.map((e) => fromJson(jsonDecode(e))).toList();
      if (decodedValue is! List<T?>) {
        throw LocalStorageObjectMisMatchError.fromMisMatchType(
            List<T?>, decodedValue.runtimeType);
      }
      return decodedValue;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveListClass<T>(String key, List<T> value,
      Map<String, dynamic> Function(T) toJson) async {
    try {
      final jsonEncodedList = value.map((e) => jsonEncode(toJson(e))).toList();
      await _sharedPreferences.setStringList(key, jsonEncodedList);
    } catch (e) {
      throw LocalStorageSaveError.fromKey(key);
    }
  }
}
