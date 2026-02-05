#!/bin/bash
set -e

echo "📊 Creating AnalyticsService (firebase_analytics ^12.1.1)..."

# Create directory
mkdir -p $BASE_DIR/core/utils/firebase

# Create analytics_service.dart
cat << 'EOF' > $BASE_DIR/core/utils/firebase/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics service.
/// Keeps firebase_analytics usage out of UI widgets.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log a custom event
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  /// Log screen view
  static Future<void> logScreen(
    String screenName, {
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Set user ID
  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set a single user property
  static Future<void> setUserProperty(
    String name,
    String? value,
  ) async {
    await _analytics.setUserProperty(
      name: name,
      value: value,
    );
  }

  /// Reset analytics data (useful on logout)
  static Future<void> reset() async {
    await _analytics.resetAnalyticsData();
  }
}
EOF

echo "✅ AnalyticsService created at $BASE_DIR/core/utils/analytics/analytics_service.dart"

# Add dependency with fixed version
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding firebase_analytics ^12.1.1 dependency..."
  flutter pub add firebase_analytics:^12.1.1
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add firebase_analytics:^12.1.1"
fi

echo "🎉 AnalyticsService setup complete."
