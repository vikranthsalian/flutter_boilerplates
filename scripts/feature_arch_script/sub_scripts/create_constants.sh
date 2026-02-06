#!/bin/bash
mkdir -p $BASE_DIR/core/constants
cat << 'EOF' > $BASE_DIR/core/constants/string_constants.dart

class StringConstants {

  static const appName = '';

}
EOF

echo "🎉 AppLogger created at $BASE_DIR/core/constants/string_constants.dart"

cat << 'EOF' > $BASE_DIR/core/constants/asset_constants.dart

class AssetConstants {

  static const appIcon = '';

}
EOF

