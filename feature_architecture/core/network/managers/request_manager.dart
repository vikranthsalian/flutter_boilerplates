import 'package:dio/dio.dart';

/// Manages CancelTokens per flow/screen to avoid leaks.
class RequestManager {
  final Map<String, CancelToken> _tokens = {};

  CancelToken create(String id) {
    final token = CancelToken();
    _tokens[id] = token;
    return token;
  }

  void storeToken(String id, CancelToken token) {
    _tokens[id] = token;
  }

  CancelToken? getToken(String id) => _tokens[id];

  void cancel(String id, [String? reason]) {
    if (_tokens.containsKey(id)) {
      _tokens[id]!.cancel(reason ?? 'Cancelled by RequestManager');
      _tokens.remove(id);
    }
  }

  void cancelAll([String? reason]) {
    for (final t in _tokens.values) {
      t.cancel(reason ?? 'Cancelled all by RequestManager');
    }
    _tokens.clear();
  }
}
