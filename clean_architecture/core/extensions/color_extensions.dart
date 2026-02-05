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
