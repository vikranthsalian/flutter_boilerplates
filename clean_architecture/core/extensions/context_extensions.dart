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
