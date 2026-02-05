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
