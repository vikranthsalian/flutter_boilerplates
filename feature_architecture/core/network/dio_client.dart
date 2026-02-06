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
