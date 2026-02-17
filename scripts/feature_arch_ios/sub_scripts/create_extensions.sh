#!/bin/bash
set -e

echo "📦 Creating Awesome-Like Flutter extensions..."

mkdir -p $BASE_DIR/core/extensions

#######################################
# context_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Screen size + orientation
  Size get size => MediaQuery.of(this).size;
  double get width => size.width;
  double get height => size.height;

  Orientation get orientation => MediaQuery.of(this).orientation;

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // Responsive flags
  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 1200;
  bool get isDesktop => width >= 1200;

  // Padding shortcuts
  EdgeInsets get mediaPadding => MediaQuery.of(this).padding;
}
EOF

#######################################
# navigation_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/navigation_extensions.dart
import 'package:flutter/material.dart';

extension NavigationExtensions on BuildContext {
  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> pushReplacement<T, R>(Widget page) =>
      Navigator.of(this).pushReplacement(MaterialPageRoute(builder: (_) => page));

  Future<T?> pushNamed<T>(String name, {Object? args}) =>
      Navigator.of(this).pushNamed(name, arguments: args);

  void popUntil(String name) =>
      Navigator.of(this).popUntil(ModalRoute.withName(name));
}
EOF

#######################################
# widget_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/widget_extensions.dart
import 'package:flutter/material.dart';

extension WidgetSpacerExtensions on num {
  Widget get heightBox => SizedBox(height: toDouble());
  Widget get widthBox => SizedBox(width: toDouble());
}

extension PaddingExtensions on Widget {
  Widget paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
  Widget paddingOnly({double left=0, double top=0, double right=0, double bottom=0}) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
}

extension FlexExtensions on Widget {
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  Widget flexible({int flex = 1}) => Flexible(flex: flex, child: this);
}
EOF

#######################################
# text_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/text_extensions.dart
import 'package:flutter/material.dart';

extension TextStyleHelpers on TextStyle? {
  TextStyle get bold => this?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
  TextStyle get italic => this?.copyWith(fontStyle: FontStyle.italic) ?? const TextStyle(fontStyle: FontStyle.italic);
  TextStyle size(double value) => this?.copyWith(fontSize: value) ?? TextStyle(fontSize: value);
  TextStyle color(Color c) => this?.copyWith(color: c) ?? TextStyle(color: c);
}

extension StringTextExtensions on String {
  Text toText({Key? key, TextStyle? style}) => Text(this, key: key, style: style);
}
EOF

#######################################
# list_map_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/list_map_extensions.dart
extension ListExtensions<T> on List<T> {
  bool get isNotEmptyList => isNotEmpty;
  bool get isEmptyList => isEmpty;
  List<T> get reversedList => reversed.toList();
}

extension MapExtensions<K,V> on Map<K,V> {
  bool get hasData => isNotEmpty;
  List<K> get keysList => keys.toList();
  List<V> get valuesList => values.toList();
}
EOF

#######################################
# date_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/date_extensions.dart
extension DateTimeFormatting on DateTime {
  String get simpleDate => "${this.day}/${this.month}/${this.year}";
  String get simpleTime => "${this.hour}:${this.minute.toString().padLeft(2,'0')}";
  String get fullDateTime => "${this.simpleDate} ${this.simpleTime}";
}
EOF

#######################################
# string_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/string_extensions.dart
extension ExtraStringExtensions on String {
  bool get isNullOrEmpty => trim().isEmpty;
  bool get isNotNullOrEmpty => trim().isNotEmpty;
}
EOF

#######################################
# async_duration_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/async_duration_extensions.dart
extension FutureExtensions<T> on Future<T> {
  Future<T> thenIgnoreError(void Function(Object) onErrorAction) async {
    try {
      return await this;
    } catch (e) {
      onErrorAction(e);
      rethrow;
    }
  }
}

extension DurationHelpers on Duration {
  String formatted() {
    return "${inHours}h ${inMinutes % 60}m ${inSeconds % 60}s";
  }
}
EOF

#######################################
# color_extensions.dart
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/color_extensions.dart
import 'package:flutter/material.dart';

extension ColorManipulation on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    return withOpacity(1.0 - amount);
  }
  Color lighten([double amount = .1]) {
    return withOpacity((1.0 - amount) + amount);
  }
}
EOF

#######################################
# barrel file
#######################################
cat << 'EOF' > $BASE_DIR/core/extensions/extensions.dart
export 'context_extensions.dart';
export 'navigation_extensions.dart';
export 'widget_extensions.dart';
export 'text_extensions.dart';
export 'list_map_extensions.dart';
export 'date_extensions.dart';
export 'string_extensions.dart';
export 'async_duration_extensions.dart';
export 'color_extensions.dart';
EOF

echo "📌 Import them with: import 'utils/extensions/extensions.dart';"
echo "✅ Awesome-like extensions created!"
