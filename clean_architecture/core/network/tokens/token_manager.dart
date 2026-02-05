import '../../cache/secure_storage.dart';

/// TokenManager uses flutter_secure_storage for sensitive tokens.
/// Replace keys or extend with rotated keys as required.
class TokenManager {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<String?> get accessToken async {
    return await AppSecureStorage.read(key: _accessKey);
  }

  static Future<String?> get refreshToken async {
    return await AppSecureStorage.read(key: _refreshKey);
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await AppSecureStorage.write(key: _accessKey, value: access);
    await AppSecureStorage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> clearTokens() async {
    await AppSecureStorage.delete(key: _accessKey);
    await AppSecureStorage.delete(key: _refreshKey);
  }
}
