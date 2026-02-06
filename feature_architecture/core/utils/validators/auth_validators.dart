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
