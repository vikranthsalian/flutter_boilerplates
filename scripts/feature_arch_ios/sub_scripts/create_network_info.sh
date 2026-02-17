#!/bin/bash
set -e

echo "🌐 Creating NetworkInfoService (network_info_plus ^7.0.0)..."

# Create directory
mkdir -p $BASE_DIR/core/utils/device

# Create network_info_service.dart
cat << 'EOF' > $BASE_DIR/core/utils/device/network_info_service.dart
import 'package:network_info_plus/network_info_plus.dart';

/// Centralized network information service.
/// Keeps network_info_plus usage out of UI widgets.
class NetworkInfoService {
  NetworkInfoService._();

  static final NetworkInfo _info = NetworkInfo();

  /// WiFi name (SSID)
  static Future<String?> get wifiName => _info.getWifiName();

  /// WiFi BSSID
  static Future<String?> get wifiBSSID => _info.getWifiBSSID();

  /// WiFi IP address
  static Future<String?> get wifiIP => _info.getWifiIP();

  /// WiFi IPv6 address
  static Future<String?> get wifiIPv6 => _info.getWifiIPv6();

  /// WiFi subnet mask
  static Future<String?> get wifiSubmask => _info.getWifiSubmask();

  /// WiFi broadcast address
  static Future<String?> get wifiBroadcast => _info.getWifiBroadcast();

  /// WiFi gateway IP
  static Future<String?> get wifiGatewayIP => _info.getWifiGatewayIP();
}
EOF

echo "✅ NetworkInfoService created at $BASE_DIR/core/utils/network/network_info_service.dart"

# Add dependency with fixed version
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding network_info_plus ^7.0.0 dependency..."
  flutter pub add network_info_plus:^7.0.0
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add network_info_plus:^7.0.0"
fi

echo "🎉 NetworkInfoService setup complete."
