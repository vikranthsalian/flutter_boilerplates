#!/bin/bash
set -e
echo "📁 Creating Flutter folder structure..."

# Paths
export $(grep -v '^#' ../../.env | xargs)
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
