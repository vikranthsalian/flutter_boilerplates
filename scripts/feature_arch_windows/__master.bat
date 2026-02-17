@echo off
setlocal enabledelayedexpansion

echo.
echo =========================================
echo     Creating Flutter Folder Structure
echo =========================================
echo.

:: ----------------------------------------------------
:: Set Project Root
:: ----------------------------------------------------
set PROJECT_ROOT=%cd%
echo PROJECT_ROOT: %PROJECT_ROOT%

set ENV_FILE=%PROJECT_ROOT%\.env

:: ----------------------------------------------------
:: Load .env if exists
:: ----------------------------------------------------
if exist "%ENV_FILE%" (
    echo 📦 Loading .env from project root
    for /f "usebackq tokens=1,2 delims==" %%A in (`type "%ENV_FILE%" ^| findstr /v "^#"`) do (
        set %%A=%%B
    )
) else (
    echo ℹ️ No .env found in project root, continuing...
)

:: Default fallback
if "%BASE_DIR%"=="" set BASE_DIR=lib

:: ----------------------------------------------------
:: Base GitHub URL (Windows folder)
:: ----------------------------------------------------
set BASE_URL=https://raw.githubusercontent.com/vikranthsalian/flutter_boilerplates/main/scripts/feature_arch_windows/sub_scripts

:: ----------------------------------------------------
:: Run All Scripts
:: ----------------------------------------------------
call :run_script create_theme.bat

echo.
echo 🎉 Folder structure created successfully!
echo.
pause
exit /b


:: ----------------------------------------------------
:: Script Runner
:: ----------------------------------------------------
:run_script
set SCRIPT_NAME=%1
echo.
echo ▶️ Running %SCRIPT_NAME%

:: Download script
curl -fsSL %BASE_URL%/%SCRIPT_NAME% -o temp_script.bat

if errorlevel 1 (
    echo ❌ Failed to download %SCRIPT_NAME%
    exit /b 1
)

:: Execute downloaded script
call temp_script.bat

:: Clean up
del temp_script.bat

exit /b