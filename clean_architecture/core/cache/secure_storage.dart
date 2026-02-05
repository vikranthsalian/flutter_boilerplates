import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Reusable secure storage wrapper.
/// Centralizes access to FlutterSecureStorage.
class AppSecureStorage {
  AppSecureStorage._();

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Write value
  static Future<void> write({required String key,required String value}) {
    return _storage.write(key: key, value: value);
  }

  /// Read value
  static Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  /// Delete value
  static Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  /// Clear all secure storage
  static Future<void> clear() {
    return _storage.deleteAll();
  }

  /// Check if key exists
  static Future<bool> contains({ required String key}) async {
    return (await _storage.read(key: key)) != null;
  }
}
