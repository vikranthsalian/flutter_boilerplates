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
run_script create_dio.sh
run_script create_go_router.sh
run_script create_env.sh
run_script create_extensions.sh
run_script create_file_picker.sh
run_script create_image_picker.sh
run_script create_logger.sh
run_script create_secure_storage.sh
run_script create_share_plus.sh
run_script create_shared_prefs.sh
run_script create_theme.sh
run_script create_validators.sh


run_script create_firebase_analytics.sh
run_script create_login.sh

echo "🎉 Folder structure created successfully!"
