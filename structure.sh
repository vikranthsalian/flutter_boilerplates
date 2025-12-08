#!/bin/bash

echo "📁 Creating Flutter folder structure..."

# ================
# COMMON
# ================
mkdir -p lib/common/di
mkdir -p lib/common/widgets
mkdir -p lib/common/error

# ================
# DATA LAYER
# ================
mkdir -p lib/data/models
mkdir -p lib/data/repositories
mkdir -p lib/data/sources/local
mkdir -p lib/data/sources/remote

# ================
# FEATURES (empty for now, dev will add per feature)
# ================
mkdir -p lib/features

# ================
# LOCALIZATIONS
# ================
mkdir -p lib/localizations

# ================
# UTILS
# ================
mkdir -p lib/utils/constants
mkdir -p lib/utils/device
mkdir -p lib/utils/formatters
mkdir -p lib/utils/helpers
mkdir -p lib/utils/http
mkdir -p lib/utils/local_storage
mkdir -p lib/utils/theme
mkdir -p lib/utils/validators

# Create logging directory
mkdir -p lib/utils/logging

# 👉 CALL create_app_logger.sh
bash app_logger.sh

# ================
# SAMPLE FILES
# ================
echo "class ApiConstants { static const baseUrl = ''; }" > lib/utils/constants/api_constants.dart
echo "class Validators {}" > lib/utils/validators/validators.dart
echo "class AppLogger { static void d(String msg) => print(msg); }" > lib/utils/logging/logger.dart
echo "class NavigationHelper {}" > lib/utils/helpers/navigation_helper.dart
echo "class AppTheme {}" > lib/utils/theme/app_theme.dart
echo "class LocalStorage {}" > lib/utils/local_storage/local_storage.dart

echo "import 'package:dio/dio.dart';" > lib/utils/http/dio_client.dart
echo "// TODO: Add Dio client implementation" >> lib/utils/http/dio_client.dart

echo "🎉 Folder structure created successfully!"
