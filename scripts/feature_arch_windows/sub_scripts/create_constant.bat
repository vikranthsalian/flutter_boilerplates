@echo off
setlocal enabledelayedexpansion

:: Default fallback
if "%BASE_DIR%"=="" set BASE_DIR=lib

:: --------------------------------------------
:: Create constants directory
:: --------------------------------------------
set CONST_DIR=%BASE_DIR%\core\constants
mkdir "%CONST_DIR%" 2>nul

echo.
echo 📁 Creating constants in %CONST_DIR%
echo.

:: --------------------------------------------
:: Create string_constants.dart
:: --------------------------------------------
(
echo class StringConstants {
echo.
echo   static const appName = '';
echo.
echo }
) > "%CONST_DIR%\string_constants.dart"

echo ✅ string_constants.dart created

:: --------------------------------------------
:: Create asset_constants.dart
:: --------------------------------------------
(
echo class AssetConstants {
echo.
echo   static const appIcon = '';
echo.
echo }
) > "%CONST_DIR%\asset_constants.dart"

echo ✅ asset_constants.dart created

echo.
echo 🎉 Constants created successfully!
echo Location: %CONST_DIR%
echo.

exit /b