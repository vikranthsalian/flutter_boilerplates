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
