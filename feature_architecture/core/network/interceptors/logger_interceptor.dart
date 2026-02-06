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
