import '../../../../../core/utils/firebase/crashlytics_service.dart';
import '../../../../../core/core/network/dio_client.dart';
import '../models/login_response_model.dart';

class LoginRemoteDatasource {
  final DioClient dio;

  LoginRemoteDatasource(this.dio);

  Future<LoginResponseModel> execute({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return LoginResponseModel.fromJson(response.data!);
    } catch (e, s) {
      CrashlyticsService.recordError(e, s);
      rethrow;
    }
  }
}
