#!/bin/bash
set -e
echo "📁 Creating Flutter folder structure..."

PROJECT_ROOT="$(pwd)"

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



SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR/sub_scripts"
echo "✅ Now inside sub_scripts:"
pwd

#bash create_pubsec.sh

bash create_constants.sh
bash create_dio.sh
bash create_env.sh
bash create_extensions.sh
bash create_file_picker.sh
bash create_image_picker.sh
bash create_logger.sh
bash create_secure_storage.sh
bash create_share_plus.sh
bash create_shared_prefs.sh
bash create_theme.sh
bash create_validators.sh


bash create_firebase_analytics.sh
bash create_feature.sh

echo "🎉 Folder structure created successfully!"
