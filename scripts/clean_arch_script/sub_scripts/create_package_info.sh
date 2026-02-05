#!/bin/bash
set -e

echo "📦 Creating PackageInfoService (package_info_plus ^9.0.0)..."

# Create directory
mkdir -p $BASE_DIR/core/utils/device

# Create package_info_service.dart
cat << 'EOF' > $BASE_DIR/core/utils/device/package_info_service.dart
import 'package:package_info_plus/package_info_plus.dart';

/// Centralized app/package information service.
/// Keeps package_info_plus usage out of UI widgets.
class PackageInfoService {
  PackageInfoService._();

  static PackageInfo? _info;

  /// Must be called once during app startup
  static Future<void> init() async {
    _info ??= await PackageInfo.fromPlatform();
  }

  static String get appName => _info?.appName ?? '';
  static String get packageName => _info?.packageName ?? '';
  static String get version => _info?.version ?? '';
  static String get buildNumber => _info?.buildNumber ?? '';
  static String get buildSignature => _info?.buildSignature ?? '';
}
EOF

echo "✅ PackageInfoService created at $BASE_DIR/core/utils/app/package_info_service.dart"

# Add dependency with fixed version
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding package_info_plus ^9.0.0 dependency..."
  flutter pub add package_info_plus:^9.0.0
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add package_info_plus:^9.0.0"
fi

echo "🎉 PackageInfoService setup complete."
