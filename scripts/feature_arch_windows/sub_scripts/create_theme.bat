@echo off
setlocal

if "%BASE_DIR%"=="" set BASE_DIR=lib

set THEME_DIR=%BASE_DIR%\core\theme
mkdir "%THEME_DIR%"

(
echo import 'package:flutter/material.dart';
echo.
echo class AppTheme {
echo   static ThemeData lightTheme = ThemeData.light();
echo   static ThemeData darkTheme = ThemeData.dark();
echo }
) > "%THEME_DIR%\app_theme.dart"

echo.
echo ✅ Theme created at %THEME_DIR%\app_theme.dart
echo.
pause