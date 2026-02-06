#!/bin/bash
set -e
echo "📁 Creating Flutter folder structure..."

PROJECT_ROOT="$(pwd)"
echo PROJECT_ROOT
ENV_FILE="$PROJECT_ROOT/.env"
# Paths
export $(grep -v '^#' $ENV_FILE | xargs)

if [ -f "$ENV_FILE" ]; then
  echo "📦 Loading .env from project root"
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "ℹ️ No .env found in project root, continuing..."
fi


BASE_URL="https://raw.githubusercontent.com/vikranthsalian/flutter_boilerplates/main/scripts/clean_arch_script/sub_scripts"

run_script () {
  local name="$1"
  echo "▶️ Running $name"
  curl -fsSL "$BASE_URL/$name" | bash
}


echo "▶️ Running clean architecture setup..."
#bash create_pubsec.sh

run_script create_constants.sh
# bash create_dio.sh
# bash create_env.sh
# bash create_extensions.sh
# bash create_file_picker.sh
# bash create_image_picker.sh
# bash create_logger.sh
# bash create_secure_storage.sh
# bash create_share_plus.sh
# bash create_shared_prefs.sh
# bash create_theme.sh
# bash create_validators.sh


# bash create_firebase_analytics.sh
# bash create_feature.sh

echo "🎉 Folder structure created successfully!"
