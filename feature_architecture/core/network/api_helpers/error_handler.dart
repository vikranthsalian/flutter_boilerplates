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
