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
