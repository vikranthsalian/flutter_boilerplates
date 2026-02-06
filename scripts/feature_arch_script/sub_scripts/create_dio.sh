#!/bin/bash
set -e

echo "🚀 Creating full Dio module integration..."

# Create directories (existing structure)
mkdir -p $BASE_DIR/core/network/interceptors
mkdir -p $BASE_DIR/core/network/tokens
mkdir -p $BASE_DIR/core/network/api_helpers
mkdir -p $BASE_DIR/core/network/managers

################################################################################
# 1) Dio integration in dio_client
#    (we rewrite dio_client to include DioLogger before retry/auth)
################################################################################
cat << 'EOF' > $BASE_DIR/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'managers/request_manager.dart';
import 'api_helpers/api_result.dart';
import 'api_helpers/error_handler.dart';
import '../utils/logging/logger.dart';
import '../../../config/env.dart';


class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  int connectTimeoutSeconds = 45;
  int receiveTimeoutSeconds = 45;
  int sendTimeoutSeconds = 45;
  late final Dio dio;
  final RequestManager requestManager = RequestManager();

  DioClient._internal() {
    final base = Env.baseUrl;
    final options = BaseOptions(
      baseUrl: base,
      connectTimeout:  Duration(seconds: connectTimeoutSeconds),
      receiveTimeout:  Duration(seconds: receiveTimeoutSeconds),
      sendTimeout:  Duration(seconds: sendTimeoutSeconds),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio = Dio(options);

    // 2) App-level logger interceptor (keeps AppLogger )
    dio.interceptors.add(LoggerInterceptor(logRequestBody: false));

    // 3) Retry logic
    dio.interceptors.add(RetryInterceptor(client: this));

    // 4) Auth (attach token, refresh & replay)
    dio.interceptors.add(AuthInterceptor(this));

    AppLogger.i('DioClient created with baseUrl: $base');
  }


  CancelToken createCancelToken([String? id]) {
    final token = CancelToken();
    if (id != null) {
      // store token in request manager using a safe API if exposed
      requestManager.storeToken(id, token);
    }
    return token;
  }

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return _wrapResponse(response, decoder);
    } on DioException catch (e) {
      AppLogger.e('Dio GET error: $path', e, e.stackTrace);
      return ApiResult.failure(ErrorHandler.message(e));
    } catch (e, st) {
      AppLogger.e('Unexpected GET error: $path', e, st);
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return _wrapResponse(response, decoder);
    } on DioException catch (e) {
      AppLogger.e('Dio POST error: $path', e, e.stackTrace);
      return ApiResult.failure(ErrorHandler.message(e));
    } catch (e, st) {
      AppLogger.e('Unexpected POST error: $path', e, st);
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return _wrapResponse(response, decoder);
    } on DioException catch (e) {
      AppLogger.e('Dio PUT error: $path', e, e.stackTrace);
      return ApiResult.failure(ErrorHandler.message(e));
    } catch (e, st) {
      AppLogger.e('Unexpected PUT error: $path', e, st);
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return _wrapResponse(response, decoder);
    } on DioException catch (e) {
      AppLogger.e('Dio DELETE error: $path', e, e.stackTrace);
      return ApiResult.failure(ErrorHandler.message(e));
    } catch (e, st) {
      AppLogger.e('Unexpected DELETE error: $path', e, st);
      return ApiResult.failure(e.toString());
    }
  }

  ApiResult<T> _wrapResponse<T>(Response response, T Function(dynamic data)? decoder) {
    try {
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        final raw = response.data;
        if (decoder != null) {
          try {
            final mapped = decoder(raw);
            return ApiResult.success(mapped);
          } catch (e, st) {
            AppLogger.e('Decoder error', e, st);
            return ApiResult.failure('Failed to parse response.');
          }
        } else {
          return ApiResult.success(raw as T);
        }
      } else {
        final errMsg = 'Server error (${response.statusCode})';
        AppLogger.e('Non-success response: $errMsg');
        return ApiResult.failure(errMsg);
      }
    } catch (e, st) {
      AppLogger.e('wrapResponse unexpected', e, st);
      return ApiResult.failure(e.toString());
    }
  }
}
EOF

################################################################################
# 2) Add storeToken method in RequestManager (safe public API)
################################################################################
cat << 'EOF' > $BASE_DIR/core/network/managers/request_manager.dart
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
EOF
#########################
# Interceptors
#########################
cat << 'EOF' > $BASE_DIR/core/network/interceptors/logger_interceptor.dart
import 'package:dio/dio.dart';
import '../../utils/logging/logger.dart';

class LoggerInterceptor extends Interceptor {
  final bool logRequestBody;
  LoggerInterceptor({this.logRequestBody = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Don't log sensitive headers like Authorization in production logs
    final headers = Map.of(options.headers);
    if (headers.containsKey('Authorization')) headers['Authorization'] = 'REDACTED';

    AppLogger.i('➡️  ${options.method} ${options.uri}');
    AppLogger.d('Headers: $headers');
    if (logRequestBody && options.data != null) AppLogger.d('Request data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.i('⬅️  ${response.statusCode} ${response.requestOptions.uri}');
    AppLogger.d('Response data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e('❌ ${err.message} (${err.response?.statusCode})', err, err.stackTrace);
    handler.next(err);
  }
}
EOF

cat << 'EOF' > $BASE_DIR/core/network/interceptors/retry_interceptor.dart
import 'dart:math';
import 'package:dio/dio.dart';
import '../../utils/logging/logger.dart';
import '../dio_client.dart';
import '../api_helpers/network_info.dart';
class RetryInterceptor extends Interceptor {
  final DioClient client;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({required this.client, this.maxRetries = 3, this.baseDelay = const Duration(milliseconds: 300)});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      // Do not retry non-retriable status codes (e.g., 4xx except 408)
      final status = err.response?.statusCode;
      if (status != null && status >= 400 && status < 500 && status != 408) {
        return handler.next(err);
      }

      if (!await NetworkInfo.isConnected) {
        AppLogger.d('RetryInterceptor: device offline, not retrying');
        return handler.next(err);
      }

      final shouldRetry = _shouldRetry(err);
      if (!shouldRetry) return handler.next(err);

      var retries = err.requestOptions.extra['retry_count'] as int? ?? 0;
      if (retries >= maxRetries) {
        AppLogger.d('RetryInterceptor: reached max retries ($maxRetries)');
        return handler.next(err);
      }

      retries++;
      err.requestOptions.extra['retry_count'] = retries;

      // Exponential backoff with jitter
      final backoffMs = _expBackoffMs(retries);
      AppLogger.d('RetryInterceptor: retry #$retries after ${backoffMs}ms for ${err.requestOptions.path}');
      await Future.delayed(Duration(milliseconds: backoffMs));

      final response = await client.dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          responseType: err.requestOptions.responseType,
          sendTimeout: err.requestOptions.sendTimeout,
          receiveTimeout: err.requestOptions.receiveTimeout,
        ),
      );
      return handler.resolve(response);
    } catch (e, st) {
      AppLogger.e('RetryInterceptor failed', e, st);
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown ||
        err.type == DioExceptionType.badResponse;
  }

  int _expBackoffMs(int retries) {
    final base = baseDelay.inMilliseconds;
    final exp = pow(2, retries).toInt();
    final jitter = Random().nextInt(100);
    return (base * exp) + jitter;
  }
}
EOF

cat << 'EOF' > $BASE_DIR/core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../tokens/token_manager.dart';
import '../../utils/logging/logger.dart';
import '../dio_client.dart';
/// AuthInterceptor attaches access token and handles refresh+replay on 401.
class AuthInterceptor extends Interceptor {
  final DioClient client;
  final String refreshPath;

  AuthInterceptor(this.client, {this.refreshPath = '/auth/refresh'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await TokenManager.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e, st) {
      AppLogger.e('AuthInterceptor onRequest error', e, st);
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final resp = err.response;
    AppLogger.e('AuthInterceptor onError: ${err.message}', err, err.stackTrace);

    if (resp?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        try {
          final token = await TokenManager.accessToken;
          final opts = Options(
            method: err.requestOptions.method,
            headers: Map<String, dynamic>.from(err.requestOptions.headers),
            responseType: err.requestOptions.responseType,
            followRedirects: err.requestOptions.followRedirects,
            validateStatus: err.requestOptions.validateStatus,
          );
          if (token != null) opts.headers?['Authorization'] = 'Bearer $token';

          final cloneResp = await client.dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: opts,
          );
          return handler.resolve(cloneResp);
        } catch (e, st) {
          AppLogger.e('AuthInterceptor replay error', e, st);
        }
      } else {
        // If refresh failed, clear tokens (app should navigate to login)
        await TokenManager.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refresh = await TokenManager.refreshToken;
      if (refresh == null) return false;

      final response = await client.dio.post(refreshPath, data: {'refreshToken': refresh});

      if (response.statusCode == 200 && response.data != null) {
        final newAccess = response.data['accessToken'] as String?;
        final newRefresh = response.data['refreshToken'] as String?;
        if (newAccess != null && newRefresh != null) {
          await TokenManager.saveTokens(newAccess, newRefresh);
          return true;
        }
      }
    } catch (e, st) {
      AppLogger.e('Token refresh failed', e, st);
    }
    return false;
  }
}
EOF

# Network info
cat << 'EOF' > $BASE_DIR/core/network/api_helpers/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  static Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
    bool _isConnected = true;
    set setIsConnected(bool val) => _isConnected = val;

    bool get getIsConnected => _isConnected;
}
EOF

# Add dependency automatically
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding Firebase Messaging dependency..."
  flutter pub add connectivity_plus
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add connectivity_plus"
fi

#########################
# ApiResult wrapper
#########################
cat << 'EOF' > $BASE_DIR/core/network/api_helpers/api_result.dart
/// Generic API result wrapper used across repositories.
class ApiResult<T> {
  final T? data;
  final String? error;

  ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(String message) => ApiResult._(error: message);

  bool get isSuccess => error == null;
}
EOF

#########################
# Error handler (maps DioException -> message)
#########################
cat << 'EOF' > $BASE_DIR/core/network/api_helpers/error_handler.dart
import 'package:dio/dio.dart';

/// Map DioException to user-friendly message (localize as needed).
class ErrorHandler {
  static String message(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout, please try again.";
      case DioExceptionType.receiveTimeout:
        return "Server took too long to respond.";
      case DioExceptionType.sendTimeout:
        return "Network too slow.";
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final serverMsg = e.response?.data?.toString();
        return "Server error${status != null ? ' ($status)' : ''}${serverMsg != null ? ': $serverMsg' : ''}";
      case DioExceptionType.connectionError:
        return "No internet connection.";
      case DioExceptionType.cancel:
        return "Request cancelled.";
      default:
        return "Unexpected error occurred.";
    }
  }
}
EOF


# Secure Token Manager (flutter_secure_storage)
#########################
cat << 'EOF' > $BASE_DIR/core/network/tokens/token_manager.dart
import '../../cache/secure_storage.dart';

/// TokenManager uses flutter_secure_storage for sensitive tokens.
/// Replace keys or extend with rotated keys as required.
class TokenManager {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<String?> get accessToken async {
    return await AppSecureStorage.read(key: _accessKey);
  }

  static Future<String?> get refreshToken async {
    return await AppSecureStorage.read(key: _refreshKey);
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await AppSecureStorage.write(key: _accessKey, value: access);
    await AppSecureStorage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> clearTokens() async {
    await AppSecureStorage.delete(key: _accessKey);
    await AppSecureStorage.delete(key: _refreshKey);
  }
}
EOF
echo "✅ TokenManager created at $BASE_DIR/core/network/tokens/token_manager.dart"

echo "🎉 TokenManager setup complete."
# Add dependency automatically
if command -v flutter >/dev/null 2>&1; then
  echo "📦 Adding Firebase Messaging dependency..."
  flutter pub add dio
else
  echo "⚠️ Flutter not found. Please run manually:"
  echo "flutter pub add dio"
fi
