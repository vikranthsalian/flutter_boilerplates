#!/bin/bash
set -e

echo "🔥 Creating CrashlyticsService (firebase_crashlytics ^5.0.7)..."

# Ensure Flutter project
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ pubspec.yaml not found. Run from Flutter project root."
  exit 1
fi

# Create directory
mkdir -p $BASE_DIR/core/utils/firebase

# Create crashlytics_service.dart
cat << 'EOF' > $BASE_DIR/core/utils/firebase/crashlytics_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized Crashlytics service.
/// Keeps firebase_crashlytics usage out of UI/widgets.
class CrashlyticsService {
  CrashlyticsService._();

  static FirebaseCrashlytics get _instance =>
      FirebaseCrashlytics.instance;

  /// Enable / disable Crashlytics (call during app init)
  static Future<void> setEnabled(bool enabled) async {
    await _instance.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Log a message
  static void log(String message) {
    _instance.log(message);
  }

  /// Record a handled error
  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Record Flutter framework errors
  static void recordFlutterError(FlutterErrorDetails details) {
    _instance.recordFlutterFatalError(details);
  }

  /// Set user identifier
  static Future<void> setUserId(String id) async {
    await _instance.setUserIdentifier(id);
  }

  /// Set custom key/value
  static Future<void> setCustomKey(String key, Object value) async {
    await _instance.setCustomKey(key, value);
  }
}
EOF

echo "✅ CrashlyticsService created at $BASE_DIR/core/utils/crashlytics/crashlytics_service.dart"

# Add dependency with fixed version
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding firebase_crashlytics ^5.0.7 dependency..."
  flutter pub add firebase_crashlytics:^5.0.7
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add firebase_crashlytics:^5.0.7"
fi

echo "🎉 CrashlyticsService setup complete."

echo "📝 Creating Crashlytics setup README..."
cat << 'EOF' > $BASE_DIR/core/utils/firebase/README_CRASHLYTICS_SETUP.md
# Firebase Crashlytics – App Initialization Guide

This document describes the **recommended production-ready setup** for
Firebase Crashlytics in this Flutter project.

---

## ✅ main.dart – Global Crashlytics Setup

Add the following code to your \`main.dart\` to ensure **all errors**
(sync, async, framework, platform) are captured correctly.

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'utils/crashlytics/crashlytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics only for non-debug builds
  await CrashlyticsService.setEnabled(kReleaseMode);

  // Flutter framework errors
  FlutterError.onError = (details) {
    CrashlyticsService.recordFlutterError(details);
  };

  // Async & platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    CrashlyticsService.recordError(error, stack, fatal: true);
    return true;
  };

  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stack) =>
        CrashlyticsService.recordError(error, stack, fatal: true),
  );
}