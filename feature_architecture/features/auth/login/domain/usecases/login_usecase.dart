import '../../../../../core/utils/firebase/analytics_service.dart';
import '../../../../../core/core/network/tokens/token_manager.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<void> execute({
    required String email,
    required String password,
  }) async {
    final result = await repository.execute(
      email: email,
      password: password,
    );

    await TokenManager.saveTokens(
      result.accessToken,
      result.refreshToken,
    );

    AnalyticsService.logEvent(
      'login_success',
      parameters: {
        'email': email,
      },
    );
  }
}
