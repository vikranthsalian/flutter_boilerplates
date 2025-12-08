#!/bin/bash

echo "📝 Creating pubspec.yaml..."

cat << 'EOF' > pubspec.yaml
name: flutter_boilerplate
description: A Flutter project with feature-based folder structure and utilities.
publish_to: "none"

version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.5

  # Networking
  dio: ^5.4.0

  # Local Storage
  shared_preferences: ^2.2.2

  # JSON / Model Utils
  json_annotation: ^4.9.0

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true

  assets:
    - assets/
EOF

echo "🎉 pubspec.yaml created successfully!"
