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
