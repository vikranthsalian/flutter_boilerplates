#!/bin/bash
set -e

echo "🔗 Creating Social Auth feature (Clean Architecture)..."

: "${BASE_DIR:?BASE_DIR is not set}"

FEATURE_DIR="$BASE_DIR/features/auth/social_auth"

mkdir -p \
  "$FEATURE_DIR/data/datasources" \
  "$FEATURE_DIR/data/models" \
  "$FEATURE_DIR/data/repositories" \
  "$FEATURE_DIR/domain/entities" \
  "$FEATURE_DIR/domain/repositories" \
  "$FEATURE_DIR/domain/usecases" \
  "$FEATURE_DIR/presentation/pages"

###############################################################################
# DOMAIN – Entity
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/entities/social_auth_entity.dart"
class SocialAuthEntity {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final bool isNewUser;
  final String provider;

  const SocialAuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.isNewUser,
    required this.provider,
  });
}
EOF

###############################################################################
# DOMAIN – Repository Contract
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/repositories/social_auth_repository.dart"
import '../entities/social_auth_entity.dart';

abstract class SocialAuthRepository {
  Future<SocialAuthEntity> authenticate({
    required String provider,
    required String providerAccessToken,
  });
}
EOF

###############################################################################
# DOMAIN – UseCase
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/usecases/social_auth_usecase.dart"
import '../../../../../core/utils/firebase/analytics_service.dart';
import '../../../../../core/network/tokens/token_manager.dart';
import '../repositories/social_auth_repository.dart';

class SocialAuthUseCase {
  final SocialAuthRepository repository;

  SocialAuthUseCase(this.repository);

  /// Returns `isNewUser` so UI can decide onboarding flow
  Future<bool> execute({
    required String provider,
    required String providerAccessToken,
  }) async {
    final result = await repository.authenticate(
      provider: provider,
      providerAccessToken: providerAccessToken,
    );

    await TokenManager.saveTokens(
      result.accessToken,
      result.refreshToken,
    );

    AnalyticsService.logEvent(
      'social_login_success',
      parameters: {
        'provider': provider,
        'is_new_user': result.isNewUser,
      },
    );

    return result.isNewUser;
  }
}
EOF

###############################################################################
# DATA – Response Model
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/models/social_auth_response_model.dart"
class SocialAuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final bool isNewUser;

  SocialAuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.isNewUser,
  });

  factory SocialAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return SocialAuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      isNewUser: json['isNewUser'] as bool,
    );
  }
}
EOF

###############################################################################
# DATA – Remote Datasource
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/datasources/social_auth_remote_datasource.dart"
import '../../../../../core/network/dio_client.dart';
import '../models/social_auth_response_model.dart';

class SocialAuthRemoteDatasource {
  final DioClient dio;

  SocialAuthRemoteDatasource(this.dio);

  Future<SocialAuthResponseModel> authenticate({
    required String provider,
    required String providerAccessToken,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/social-login',
      data: {
        'provider': provider,
        'accessToken': providerAccessToken,
      },
    );

    return SocialAuthResponseModel.fromJson(response.data!);
  }
}
EOF

###############################################################################
# DATA – Repository Implementation
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/repositories/social_auth_repository_impl.dart"
import '../../domain/entities/social_auth_entity.dart';
import '../../domain/repositories/social_auth_repository.dart';
import '../datasources/social_auth_remote_datasource.dart';

class SocialAuthRepositoryImpl implements SocialAuthRepository {
  final SocialAuthRemoteDatasource remote;

  SocialAuthRepositoryImpl(this.remote);

  @override
  Future<SocialAuthEntity> authenticate({
    required String provider,
    required String providerAccessToken,
  }) async {
    final result = await remote.authenticate(
      provider: provider,
      providerAccessToken: providerAccessToken,
    );

    return SocialAuthEntity(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      expiresIn: result.expiresIn,
      isNewUser: result.isNewUser,
      provider: provider,
    );
  }
}
EOF

###############################################################################
# PRESENTATION – Social Auth Page
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/presentation/pages/social_auth_page.dart"
import 'package:flutter/material.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../domain/usecases/social_auth_usecase.dart';
import '../../data/datasources/social_auth_remote_datasource.dart';
import '../../data/repositories/social_auth_repository_impl.dart';
import '../../../../../core/auth/auth_service.dart';

class SocialAuthPage extends StatefulWidget {
  const SocialAuthPage({super.key});

  @override
  State<SocialAuthPage> createState() => _SocialAuthPageState();
}

class _SocialAuthPageState extends State<SocialAuthPage> {
  late final SocialAuthUseCase _useCase;
   final AuthService _authService = AuthService(); // Singleton instance
  @override
  void initState() {
    super.initState();

  }

  Future<void> _login(String provider) async {
    try {
      // TODO: Replace with real provider SDK token
      const providerToken = 'provider_access_token';

      final isNewUser = await _authService.socialLogin(
        provider: provider,
        providerAccessToken: providerToken,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNewUser
                ? 'Welcome! Complete your profile'
                : 'Login successful',
          ),
        ),
      );

      // TODO:
      // if (isNewUser) navigate to onboarding
      // else navigate to home
    } catch (e) {
      AppLogger.e('Social login failed', e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Social login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Continue with')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _login('google'),
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _login('apple'),
              child: const Text('Continue with Apple'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _login('facebook'),
              child: const Text('Continue with Facebook'),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

echo "✅ Social Auth feature (with refresh token + isNewUser) created successfully."
