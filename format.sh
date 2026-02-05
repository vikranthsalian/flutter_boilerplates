#!/bin/bash
set -e

echo "🔧 Running Dart & Flutter auto-fixes..."

# Ensure we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ pubspec.yaml not found. Run this from Flutter project root."
  exit 1
fi

echo "📦 Getting dependencies..."
flutter pub get

echo "🧠 Applying Dart analyzer fixes (imports, lints, migrations)..."
dart fix --apply

echo "🎨 Formatting Dart files..."
dart format .

#echo "🔍 Running Flutter analyze..."
#flutter analyze
#
#echo "✅ Fix completed successfully!"
