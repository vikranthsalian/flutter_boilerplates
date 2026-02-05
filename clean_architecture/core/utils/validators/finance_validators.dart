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
