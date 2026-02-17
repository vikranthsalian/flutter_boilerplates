#!/bin/bash
set -e

echo "📨 Creating Firebase Messaging service & README..."


###############################################################################
# Create service
###############################################################################
mkdir -p $BASE_DIR/core/utils/firebase

cat << 'EOF' > $BASE_DIR/core/utils/firebase/messaging_service.dart
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firebase Messaging service.
/// Keeps firebase_messaging usage out of UI widgets.
class MessagingService {
  MessagingService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  /// Request notification permissions (iOS / Android 13+)
  static Future<NotificationSettings> requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    return _messaging.getToken();
  }

  /// Listen for token refresh
  static Stream<String> onTokenRefresh() {
    return _messaging.onTokenRefresh;
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Foreground message handler
  static void onMessage(
    void Function(RemoteMessage message) handler,
  ) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// App opened from background notification
  static void onMessageOpenedApp(
    void Function(RemoteMessage message) handler,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Background / terminated message handler
  static Future<void> registerBackgroundHandler(
    Future<void> Function(RemoteMessage message) handler,
  ) async {
    FirebaseMessaging.onBackgroundMessage(handler);
  }
}
EOF
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding Firebase Messaging dependency..."
  flutter pub add firebase_messaging
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add firebase_messaging"
fi
###############################################################################
# Create README
###############################################################################
cat << 'EOF' > README_FIREBASE_MESSAGING.md
# Firebase Cloud Messaging (FCM) – Complete Setup Guide

This document defines the **official, production-ready setup**
for Firebase Cloud Messaging in this project.

---

## 📦 Dependency

```yaml
firebase_messaging: ^16.1.1
