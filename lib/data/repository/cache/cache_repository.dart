import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheRepository {
  static const _mainCacheKey = '__main_cache__';
  static const _databaseKey = '__database__key__';
  static late final CacheManager instance;

  CacheRepository() {
    instance = CacheManager(
      Config(
        _mainCacheKey,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 20,
        repo: JsonCacheInfoRepository(databaseName: _databaseKey),
        fileService: HttpFileService(),
      ),
    );
  }

  Future<void> clearCache() async {
    await instance.emptyCache();
  }

  Future<void> removeFile(String url) async {
    await instance.removeFile(url);
  }

  // write
  Future<void> writeString(String key, String value) async {
    await instance.putFile(key, Uint8List.fromList(value.codeUnits));
  }

  Future<void> writeBytes(String key, Uint8List value) async {
    await instance.putFile(key, value);
  }

  // list
  Future<List<String>> writeList(String key, List<dynamic> values) async {
    List<String> keys = [];
    for (int i = 0; i < values.length; i++) {
      String newKey = '$key-$i';
      await instance.putFile(newKey, Uint8List.fromList(values[i].codeUnits));
      keys.add(newKey);
    }
    return keys;
  }

  // Map
  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await instance.putFile(key, Uint8List.fromList(value.toString().codeUnits));
  }

  //Object
  Future<void> writeObject(String key, Object object,
      {Object? Function(dynamic)? toEncodable}) async {
    // json encode
    String values = json.encode(object, toEncodable: toEncodable);
    await instance.putFile(key, Uint8List.fromList(values.codeUnits));
  }

  // read
  Future<String?> readString(String key) async {
    final file = await instance.getFileFromCache(key);
    if (file == null) {
      return null;
    }
    return String.fromCharCodes(file.file.readAsBytesSync());
  }

  Future<Uint8List?> readBytes(String key) async {
    final file = await instance.getFileFromCache(key);
    if (file == null) {
      return null;
    }
    return file.file.readAsBytesSync();
  }

  // list
  Future<List<String>?> readList(String key) async {
    List<String> values = [];
    int i = 0;
    while (true) {
      String newKey = '$key-$i';
      final file = await instance.getFileFromCache(newKey);
      if (file == null) {
        break;
      }
      values.add(String.fromCharCodes(file.file.readAsBytesSync()));
      i++;
    }
    if (values.isEmpty) {
      return null;
    }
    return values;
  }

  // Map
  Future<Map<String, dynamic>?> readMap(String key) async {
    final file = await instance.getFileFromCache(key);
    if (file == null) {
      return null;
    }
    return json.decode(String.fromCharCodes(file.file.readAsBytesSync()));
  }

  //Object
  Future<Object?> readObject(String key,
      {Object? Function(Object?, Object?)? reviver}) async {
    final file = await instance.getFileFromCache(key);
    if (file == null) {
      return null;
    }
    return json.decode(String.fromCharCodes(file.file.readAsBytesSync()),
        reviver: reviver);
  }

  void dispose() {
    instance.dispose();
  }
}

class TempCache {
  TempCache() : _cache = <String, Object>{};

  final Map<String, Object> _cache;

  void write<T extends Object>({required String key, required T value}) {
    _cache[key] = value;
  }

  T? read<T extends Object>({required String key}) {
    final value = _cache[key];
    if (value is T) return value;
    return null;
  }
}

class CacheKeys {}
