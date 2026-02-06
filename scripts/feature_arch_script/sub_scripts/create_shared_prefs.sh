#!/bin/bash
set -e

echo "💾 Creating reusable SharedPrefs wrapper..."

# Create directory
mkdir -p $BASE_DIR/core/cache

# Create shared_prefs.dart
cat << 'EOF' > $BASE_DIR/core/cache/shared_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Reusable SharedPreferences wrapper.
/// Use for NON-SENSITIVE data only.
class SharedPrefs {
  SharedPrefs._();

  static SharedPreferences? _prefs;

  /// Must be called once during app startup
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─────────── String ───────────
  static Future<bool> setString(String key, String value) async {
    await init();
    return _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // ─────────── Bool ───────────
  static Future<bool> setBool(String key, bool value) async {
    await init();
    return _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // ─────────── Int ───────────
  static Future<bool> setInt(String key, int value) async {
    await init();
    return _prefs!.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // ─────────── Double ───────────
  static Future<bool> setDouble(String key, double value) async {
    await init();
    return _prefs!.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  // ─────────── String List ───────────
  static Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return _prefs!.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // ─────────── Utilities ───────────
  static Future<bool> remove(String key) async {
    await init();
    return _prefs!.remove(key);
  }

  static Future<bool> clear() async {
    await init();
    return _prefs!.clear();
  }

  static bool contains(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}
EOF

echo "✅ SharedPrefs created at $BASE_DIR/core/cache/shared_prefs.dart"

# Add dependency automatically
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding shared_preferences dependency..."
  flutter pub add shared_preferences
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add shared_preferences"
fi

echo "✅ SharedPrefs setup complete."
