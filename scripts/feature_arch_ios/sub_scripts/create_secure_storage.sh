#!/bin/bash
set -e

echo "🔐 Creating reusable SecureStorage wrapper..."

# Create directory
mkdir -p $BASE_DIR/core/cache

# Create secure_storage.dart
cat << 'EOF' > $BASE_DIR/core/cache/secure_storage.dart
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
EOF

echo "✅ SecureStorage created at $BASE_DIR/core/cache/secure_storage.dart"

# Add dependency if Flutter is available
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding flutter_secure_storage dependency..."
  flutter pub add flutter_secure_storage
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add flutter_secure_storage"
fi

echo "✅ SecureStorage setup complete."
