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
