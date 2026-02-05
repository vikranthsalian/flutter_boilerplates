#!/bin/bash
set -e

echo "🔗 Creating ShareService using SharePlus.instance (share_plus ^12.0.1)..."

# Create directory
mkdir -p $BASE_DIR/core/services

# Create share_service.dart
cat << 'EOF' > $BASE_DIR/core/services/share_service.dart
import 'package:share_plus/share_plus.dart';

/// Centralized share utility using SharePlus.instance (latest API).
/// Keeps plugin usage isolated from UI.
class ShareService {
  ShareService._();

  /// Share plain text
  static Future<void> shareText(
    String text, {
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
      ),
    );
  }

  /// Share a URL
  static Future<void> shareUrl(
    String url, {
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: url,
        subject: subject,
      ),
    );
  }

  /// Share a single file
  static Future<void> shareFile(
    XFile file, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        text: text,
        subject: subject,
      ),
    );
  }

  /// Share multiple files
  static Future<void> shareFiles(
    List<XFile> files, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: files,
        text: text,
        subject: subject,
      ),
    );
  }
}
EOF

echo "✅ ShareService created at $BASE_DIR/core/utils/share/share_service.dart"

# Add dependency with fixed version
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding share_plus ^12.0.1 dependency..."
  flutter pub add share_plus:^12.0.1
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add share_plus:^12.0.1"
fi

echo "✅ ShareService setup complete."
