##!/bin/bash
#set -e
#
#echo "🚀 Creating full Talker Logger module..."
#
#mkdir -p $BASE_DIR/core/utils/talker
#################################################################################
## 1) Talker global instance
#################################################################################
#cat << 'EOF' > $BASE_DIR/core/utils/talker/talker_logger.dart
#import 'package:talker/talker.dart';
#import 'package:talker_console/talker_console.dart';
#
#// Global Talker instance — configure settings here.
#final talker = Talker(
#  settings: const TalkerSettings(
#    enabled: true,
#    useConsoleLogs: true,
#    maxHistoryItems: 1000,
#  ),
#  reporters: [
#    TalkerConsole(), // prints pretty console logs
#    // Add file reporter, Sentry reporter etc. as needed
#  ],
#);
#EOF
#
#
#################################################################################
## 2) Provide example Talker wiring for main.dart (developer copy/paste)
#################################################################################
#cat << 'EOF' > $BASE_DIR/core/utils/talker/TALKER_INTEGRATION.md
#Add this to your main.dart to capture global Flutter errors with Talker:
#
#import 'package:flutter/material.dart';
#import 'utils/talker/talker_logger.dart';
#import 'package:flutter/widgets.dart';
#
#void main() {
#  WidgetsFlutterBinding.ensureInitialized();
#
#  FlutterError.onError = (details) {
#    talker.handle(details.exception, details.stack);
#    // still print to console
#    FlutterError.presentError(details);
#  };
#
#  PlatformDispatcher.instance.onError = (error, stack) {
#    talker.handle(error, stack);
#    return true;
#  };
#
#  runApp(const MyApp());
#}
#
#You can also show the Talker console UI or export logs using talker reporters.
#EOF
#
#################################################################################
## 3) README reminder to add dependencies
#################################################################################
#cat << 'EOF' > $BASE_DIR/core/utils/talker/README_TALKER.md
#Talker integration added.
#
#Please update pubspec.yaml with these dependencies (example versions — pick latest compatible):
#
#dependencies:
#  dio: ^5.0.0
#  talker: ^4.0.0
#  talker_console: ^1.0.0
#  talker_dio_logger: ^4.0.0
#  flutter_secure_storage: ^8.0.0
#  connectivity_plus: ^4.0.0
#
#Then run:
#  flutter pub get
#
#Notes:
#- talker_console is used to pretty-print in debug console.
#- You can add other talker reporters (file reporter, sentry reporter) as required.
#- TalkerDioLogger is added to DioClient before retry/auth so you see raw requests/responses.
#EOF
#
#echo "✅ Talker + Dio integration files created."
#echo ""
#echo "⚠️ Post setup steps:"
#echo "  1) Add packages to pubspec.yaml (dio, talker, talker_console, talker_dio_logger, connectivity_plus, flutter_secure_storage)."
#echo "  2) Run: flutter pub get"
#echo "  3) Copy TALKER_INTEGRATION.md snippet into your main.dart to capture global errors."
#echo ""
#echo "Done. 🎉"
