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
