#!/bin/bash
set -e

echo "🔐 Creating AuthService (No DI, Manual Composition)..."

: "${BASE_DIR:?BASE_DIR is not set}"

AUTH_DIR="$BASE_DIR/core/auth"
mkdir -p "$AUTH_DIR"

cat << 'EOF' > "$AUTH_DIR/auth_service.dart"
import '../network/dio_client.dart';
import '../network/tokens/token_manager.dart';

// ---------------- LOGIN ----------------
import '../../features/auth/login/data/datasources/login_remote_datasource.dart';
import '../../features/auth/login/data/repositories/login_repository_impl.dart';
import '../../features/auth/login/domain/usecases/login_usecase.dart';

// ---------------- SIGNUP ----------------
import '../../features/auth/signup/data/datasources/signup_remote_datasource.dart';
import '../../features/auth/signup/data/repositories/signup_repository_impl.dart';
import '../../features/auth/signup/domain/usecases/signup_usecase.dart';

// ---------------- SOCIAL AUTH ----------------
import '../../features/auth/social_auth/data/datasources/social_auth_remote_datasource.dart';
import '../../features/auth/social_auth/data/repositories/social_auth_repository_impl.dart';
import '../../features/auth/social_auth/domain/usecases/social_auth_usecase.dart';

// ---------------- FORGOT PASSWORD ----------------
import '../../features/auth/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import '../../features/auth/forgot_password/data/repositories/forgot_password_repository_impl.dart';
import '../../features/auth/forgot_password/domain/usecases/forgot_password_usecase.dart';

// ---------------- RESET PASSWORD ----------------
import '../../features/auth/reset_password/data/datasources/reset_password_remote_datasource.dart';
import '../../features/auth/reset_password/data/repositories/reset_password_repository_impl.dart';
import '../../features/auth/reset_password/domain/usecases/reset_password_usecase.dart';

/// AuthService acts as a facade over all auth use cases.
/// No DI container required. Manual composition.
class AuthService {
  late final LoginUseCase _loginUseCase;
  late final SignupUseCase _signupUseCase;
  late final SocialAuthUseCase _socialAuthUseCase;
  late final ForgotPasswordUseCase _forgotPasswordUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;

   // ---------------------------------------------------------------------------
   // Singleton Setup
   // ---------------------------------------------------------------------------

   static final AuthService _instance = AuthService._internal();

   factory AuthService() => _instance;

   AuthService._internal() {
     _init();
   }

  void _init() {
    final dio = DioClient();

    // ---------------- LOGIN ----------------
    final loginRemote = LoginRemoteDatasource(dio);
    final loginRepo = LoginRepositoryImpl(loginRemote);
    _loginUseCase = LoginUseCase(loginRepo);

    // ---------------- SIGNUP ----------------
    final signupRemote = SignupRemoteDatasource(dio);
    final signupRepo = SignupRepositoryImpl(signupRemote);
    _signupUseCase = SignupUseCase(signupRepo);

    // ---------------- SOCIAL AUTH ----------------
    final socialRemote = SocialAuthRemoteDatasource(dio);
    final socialRepo = SocialAuthRepositoryImpl(socialRemote);
    _socialAuthUseCase = SocialAuthUseCase(socialRepo);

    // ---------------- FORGOT PASSWORD ----------------
    final forgotRemote = ForgotPasswordRemoteDatasource(dio);
    final forgotRepo = ForgotPasswordRepositoryImpl(forgotRemote);
    _forgotPasswordUseCase = ForgotPasswordUseCase(forgotRepo);

    // ---------------- RESET PASSWORD ----------------
    final resetRemote = ResetPasswordRemoteDatasource(dio);
    final resetRepo = ResetPasswordRepositoryImpl(resetRemote);
    _resetPasswordUseCase = ResetPasswordUseCase(resetRepo);
  }

  // ---------------------------------------------------------------------------
  // AUTH STATUS
  // ---------------------------------------------------------------------------

  Future<bool> isLoggedIn() async {
    final token = await TokenManager.accessToken;
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  Future<void> login({
    required String email,
    required String password,
  }) {
    return _loginUseCase.execute(
      email: email,
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // SIGNUP
  // ---------------------------------------------------------------------------

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return _signupUseCase.execute(
      name: name,
      email: email,
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // SOCIAL LOGIN
  // ---------------------------------------------------------------------------

  /// Returns true if user is new (for onboarding)
  Future<bool> socialLogin({
    required String provider,
    required String providerAccessToken,
  }) {
    return _socialAuthUseCase.execute(
      provider: provider,
      providerAccessToken: providerAccessToken,
    );
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> forgotPassword({
    required String email,
  }) {
    return _forgotPasswordUseCase.execute(email: email);
  }

  // ---------------------------------------------------------------------------
  // RESET PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _resetPasswordUseCase.execute(
      token: token,
      password: newPassword,
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await TokenManager.clearTokens();
  }
}
EOF

echo "✅ AuthService created at core/auth/auth_service.dart"
