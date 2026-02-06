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
