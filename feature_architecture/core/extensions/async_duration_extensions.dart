extension FutureExtensions<T> on Future<T> {
  Future<T> thenIgnoreError(void Function(Object) onErrorAction) async {
    try {
      return await this;
    } catch (e) {
      onErrorAction(e);
      rethrow;
    }
  }
}

extension DurationHelpers on Duration {
  String formatted() {
    return "${inHours}h ${inMinutes % 60}m ${inSeconds % 60}s";
  }
}
