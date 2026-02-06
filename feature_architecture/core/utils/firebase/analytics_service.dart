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
