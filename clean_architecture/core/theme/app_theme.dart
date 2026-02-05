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
