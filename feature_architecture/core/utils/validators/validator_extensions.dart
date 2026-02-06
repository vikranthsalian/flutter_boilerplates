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
