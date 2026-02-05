#!/bin/bash
set -e

echo "🖼️ Creating ImagePickerService (image_picker ^1.2.1)..."

# Create directory
mkdir -p $BASE_DIR/core/services

# Create image_picker_service.dart
cat << 'EOF' > $BASE_DIR/core/services/image_picker_service.dart
import 'package:image_picker/image_picker.dart';

/// Centralized image picker service.
/// Keeps image_picker usage out of UI widgets.
class ImagePickerService {
  ImagePickerService._();

  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<XFile?> pickFromGallery({
    int imageQuality = 85,
  }) async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
  }

  /// Pick image from camera
  static Future<XFile?> pickFromCamera({
    int imageQuality = 85,
  }) async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
  }

  /// Pick multiple images from gallery
  static Future<List<XFile>> pickMultiple({
    int imageQuality = 85,
  }) async {
    return _picker.pickMultiImage(
      imageQuality: imageQuality,
    );
  }
}
EOF

echo "✅ ImagePickerService created at $BASE_DIR/core/utils/media/image_picker_service.dart"

# Add dependency with fixed version
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding image_picker ^1.2.1 dependency..."
  flutter pub add image_picker:^1.2.1
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add image_picker:^1.2.1"
fi

echo "✅ ImagePickerService setup complete."
