#!/bin/bash

cat << 'EOF' > lib/utils/logging/logger.dart
import 'dart:developer' as developer;

class AppLogger {
  static bool enabled = true;

  static void d(String message, [Object? error, StackTrace? stack]) {
    if (!enabled) return;
    developer.log(message, name: 'DEBUG', error: error, stackTrace: stack);
  }

  static void i(String message) {
    if (!enabled) return;
    developer.log(message, name: 'INFO');
  }

  static void e(String message, [Object? error, StackTrace? stack]) {
    developer.log(message, name: 'ERROR', error: error, stackTrace: stack);
  }
}
EOF

echo "🎉 AppLogger created at lib/utils/logging/logger.dart"
