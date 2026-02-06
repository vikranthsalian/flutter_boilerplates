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


# 2️⃣ Clone boilerplates repo
TOOLS_DIR="$PROJECT_ROOT/.flutter_boilerplates"

if [ ! -d "$TOOLS_DIR" ]; then
  echo "⬇️ Cloning Flutter Boilerplates repo..."
  git clone https://github.com/vikranthsalian/flutter_boilerplates.git "$TOOLS_DIR"
else
  echo "✅ Flutter Boilerplates already present"
fi

# 3️⃣ Run scripts FROM THE CLONED REPO
SCRIPTS_DIR="$TOOLS_DIR/scripts/clean_arch_script"

if [ ! -d "$SCRIPTS_DIR/sub_scripts" ]; then
  echo "❌ sub_scripts not found in cloned repo"
  echo "   Expected: $SCRIPTS_DIR/sub_scripts"
  exit 1
fi

echo "▶️ Running clean architecture setup..."
cd "$SCRIPTS_DIR/sub_scripts"
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
