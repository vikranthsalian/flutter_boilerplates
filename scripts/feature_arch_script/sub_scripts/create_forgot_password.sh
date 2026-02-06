#!/bin/bash
set -e

echo "📧 Creating Forgot Password feature (Clean Architecture)..."

: "${BASE_DIR:?BASE_DIR is not set}"

FEATURE_DIR="$BASE_DIR/features/auth/forgot_password"

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
cat << 'EOF' > "$FEATURE_DIR/domain/entities/forgot_password_entity.dart"
class ForgotPasswordEntity {
  final bool success;

  const ForgotPasswordEntity({required this.success});
}
EOF

###############################################################################
# DOMAIN – Repository Contract
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/repositories/forgot_password_repository.dart"
import '../entities/forgot_password_entity.dart';

abstract class ForgotPasswordRepository {
  Future<ForgotPasswordEntity> sendResetLink({
    required String email,
  });
}
EOF

###############################################################################
# DOMAIN – UseCase
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/usecases/forgot_password_usecase.dart"
import '../../../../../core/utils/firebase/analytics_service.dart';
import '../repositories/forgot_password_repository.dart';

class ForgotPasswordUseCase {
  final ForgotPasswordRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> execute({required String email}) async {
    await repository.sendResetLink(email: email);

    AnalyticsService.logEvent(
      'forgot_password_requested',
      parameters: {'email': email},
    );
  }
}
EOF

###############################################################################
# DATA – Response Model
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/models/forgot_password_response_model.dart"
class ForgotPasswordResponseModel {
  final bool success;

  ForgotPasswordResponseModel({required this.success});

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      success: json['success'] as bool,
    );
  }
}
EOF

###############################################################################
# DATA – Remote Datasource
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/datasources/forgot_password_remote_datasource.dart"
import '../../../../../core/network/dio_client.dart';
import '../models/forgot_password_response_model.dart';

class ForgotPasswordRemoteDatasource {
  final DioClient dio;

  ForgotPasswordRemoteDatasource(this.dio);

  Future<ForgotPasswordResponseModel> sendResetLink({
    required String email,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      data: {'email': email},
    );

    return ForgotPasswordResponseModel.fromJson(response.data!);
  }
}
EOF

###############################################################################
# DATA – Repository Implementation
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/repositories/forgot_password_repository_impl.dart"
import '../../domain/entities/forgot_password_entity.dart';
import '../../domain/repositories/forgot_password_repository.dart';
import '../datasources/forgot_password_remote_datasource.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ForgotPasswordRemoteDatasource remote;

  ForgotPasswordRepositoryImpl(this.remote);

  @override
  Future<ForgotPasswordEntity> sendResetLink({
    required String email,
  }) async {
    final result = await remote.sendResetLink(email: email);
    return ForgotPasswordEntity(success: result.success);
  }
}
EOF

###############################################################################
# PRESENTATION – Forgot Password Page
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/presentation/pages/forgot_password_page.dart"
import 'package:flutter/material.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../../../../core/utils/validators/auth_validators.dart';
import '../../../../../core/utils/validators/string_validators.dart';
import '../../../../../core/utils/validators/validator_extensions.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../data/datasources/forgot_password_remote_datasource.dart';
import '../../data/repositories/forgot_password_repository_impl.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  late final ForgotPasswordUseCase _useCase;

  @override
  void initState() {
    super.initState();
    _useCase = ForgotPasswordUseCase(
      ForgotPasswordRepositoryImpl(
        ForgotPasswordRemoteDatasource(DioClient()),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _useCase.execute(email: _emailCtrl.text.trim());
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset link sent')),
      );
    } catch (e) {
      AppLogger.e('Forgot password failed', e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => [
                  (val) => StringValidators.required(val),
                  (val) => AuthValidators.email(val),
                ].validate(v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Send Reset Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Forgot Password feature created successfully."
