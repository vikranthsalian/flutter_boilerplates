#!/bin/bash
set -e

echo "🔐 Creating AuthService..."

: "${BASE_DIR:?BASE_DIR is not set}"

AUTH_DIR="$BASE_DIR/core/auth"
mkdir -p "$AUTH_DIR"

###############################################################################
# AuthService
###############################################################################
cat << 'EOF' > "$AUTH_DIR/auth_service.dart"
import '../network/tokens/token_manager.dart';

import '../../features/auth/login/domain/usecases/login_usecase.dart';
import '../../features/auth/signup/domain/usecases/signup_usecase.dart';
import '../../features/auth/social_auth/domain/usecases/social_auth_usecase.dart';
import '../../features/auth/forgot_password/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/reset_password/domain/usecases/reset_password_usecase.dart';

/// AuthService is a facade over all auth-related use cases.
/// UI or higher layers should ONLY talk to this class.
class AuthService {
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final SocialAuthUseCase _socialAuthUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthService({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required SocialAuthUseCase socialAuthUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _loginUseCase = loginUseCase,
        _signupUseCase = signupUseCase,
        _socialAuthUseCase = socialAuthUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase;

  // ---------------------------------------------------------------------------
  // AUTH STATUS
  // ---------------------------------------------------------------------------

  Future<bool> isLoggedIn() async {
    final token = await TokenManager.accessToken;
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // LOGIN / SIGNUP
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

  /// Returns true if this is a new user (for onboarding)
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
  // PASSWORD FLOWS
  // ---------------------------------------------------------------------------

  Future<void> forgotPassword({
    required String email,
  }) {
    return _forgotPasswordUseCase.execute(email: email);
  }

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
