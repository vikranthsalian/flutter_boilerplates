#!/bin/bash
set -e

echo "🛡️ Creating enterprise-grade validators..."

mkdir -p $BASE_DIR/core/utils/validators

################################################################################
# validators.dart (public API)
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/validators.dart
export 'string_validators.dart';
export 'number_validators.dart';
export 'date_validators.dart';
export 'auth_validators.dart';
export 'finance_validators.dart';
export 'validator_extensions.dart';
EOF

################################################################################
# string_validators.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/string_validators.dart
class StringValidators {
  static String? required(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? minLength(String? value, int min, {String? message}) {
    if (value == null || value.length < min) {
      return message ?? 'Minimum $min characters required';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? message}) {
    if (value != null && value.length > max) {
      return message ?? 'Maximum $max characters allowed';
    }
    return null;
  }

  static String? alpha(String? value, {String message = 'Only letters allowed'}) {
    if (value == null || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) return message;
    return null;
  }

  static String? alphaNumeric(String? value, {String message = 'Only letters and numbers allowed'}) {
    if (value == null || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) return message;
    return null;
  }

  static String? regex(String? value, RegExp pattern, {String message = 'Invalid format'}) {
    if (value == null || !pattern.hasMatch(value)) return message;
    return null;
  }
}
EOF

################################################################################
# number_validators.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/number_validators.dart
class NumberValidators {
  static String? numeric(String? value, {String message = 'Only numbers allowed'}) {
    if (value == null || num.tryParse(value) == null) return message;
    return null;
  }

  static String? min(num value, num min, {String? message}) {
    if (value < min) return message ?? 'Minimum value is $min';
    return null;
  }

  static String? max(num value, num max, {String? message}) {
    if (value > max) return message ?? 'Maximum value is $max';
    return null;
  }
}
EOF

################################################################################
# date_validators.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/date_validators.dart
class DateValidators {
  static String? past(DateTime date, {String message = 'Date must be in the past'}) {
    if (date.isAfter(DateTime.now())) return message;
    return null;
  }

  static String? future(DateTime date, {String message = 'Date must be in the future'}) {
    if (date.isBefore(DateTime.now())) return message;
    return null;
  }

  static String? age(DateTime dob, {int min = 18, String? message}) {
    final age = DateTime.now().year - dob.year;
    if (age < min) return message ?? 'Minimum age is $min';
    return null;
  }
}
EOF

################################################################################
# auth_validators.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/auth_validators.dart
class AuthValidators {
  static String? email(String? value, {String message = 'Invalid email'}) {
    if (value == null ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return message;
    return null;
  }

  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = true,
  }) {
    if (value == null || value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (requireNumber && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    if (requireSpecialChar && !RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain a special character';
    }
    return null;
  }

  static String? match(String? value, String? other, {String message = 'Values do not match'}) {
    if (value != other) return message;
    return null;
  }
}
EOF

################################################################################
# finance_validators.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/finance_validators.dart
class FinanceValidators {
  static String? cardNumber(String? value) {
    if (value == null) return 'Invalid card number';
    final digits = value.replaceAll(RegExp(r'\\D'), '');
    int sum = 0;
    bool even = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int d = int.parse(digits[i]);
      if (even) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      even = !even;
    }
    return sum % 10 == 0 ? null : 'Invalid card number';
  }

  static String? cvv(String? value) {
    if (value == null || !RegExp(r'^\\d{3,4}$').hasMatch(value)) {
      return 'Invalid CVV';
    }
    return null;
  }

  static String? expiry(String? value) {
    if (value == null || !RegExp(r'^(0[1-9]|1[0-2])\\/\\d{2}$').hasMatch(value)) {
      return 'Invalid expiry date';
    }
    return null;
  }
}
EOF

################################################################################
# validator_extensions.dart
################################################################################
cat << 'EOF' > $BASE_DIR/core/utils/validators/validator_extensions.dart
typedef Validator<T> = String? Function(T value);

extension ValidatorCompose<T> on List<Validator<T>> {
  String? validate(T value) {
    for (final v in this) {
      final res = v(value);
      if (res != null) return res;
    }
    return null;
  }
}
EOF

echo "✅ Validators created successfully!"
