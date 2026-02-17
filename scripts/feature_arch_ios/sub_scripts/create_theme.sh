#!/bin/bash
set -e

echo "🎨 Creating App Theme (Light & Dark)..."

mkdir -p $BASE_DIR/core/theme

################################################################################
# app_colors.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized color palette.
/// Do NOT use Colors.* directly in widgets.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF22C55E);

  // Light theme
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF020617);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Common
  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFFE5E7EB);
}
EOF

################################################################################
# app_theme.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide theme configuration
class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.lightTextPrimary,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.lightTextPrimary,
    ),
    dividerColor: AppColors.border,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.darkTextPrimary,
      onSurface: AppColors.darkTextPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkTextPrimary,
    ),
    dividerColor: AppColors.darkTextSecondary.withOpacity(0.2),
  );

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: secondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    );
  }
}
EOF

################################################################################
# theme.dart (barrel)
################################################################################
cat << 'EOF' > $BASE_DIR/core/theme/theme.dart
export 'app_colors.dart';
export 'app_theme.dart';
EOF

echo "✅ App theme created successfully!"
