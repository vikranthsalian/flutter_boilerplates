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
