#!/bin/bash
set -e

echo "🔁 Creating Reset Password feature (Clean Architecture)..."

: "${BASE_DIR:?BASE_DIR is not set}"

FEATURE_DIR="$BASE_DIR/features/auth/reset_password"

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
cat << 'EOF' > "$FEATURE_DIR/domain/entities/reset_password_entity.dart"
class ResetPasswordEntity {
  final bool success;

  const ResetPasswordEntity({required this.success});
}
EOF

###############################################################################
# DOMAIN – Repository Contract
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/repositories/reset_password_repository.dart"
import '../entities/reset_password_entity.dart';

abstract class ResetPasswordRepository {
  Future<ResetPasswordEntity> resetPassword({
    required String token,
    required String password,
  });
}
EOF

###############################################################################
# DOMAIN – UseCase
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/usecases/reset_password_usecase.dart"
import '../../../../../core/utils/firebase/analytics_service.dart';
import '../repositories/reset_password_repository.dart';

class ResetPasswordUseCase {
  final ResetPasswordRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute({
    required String token,
    required String password,
  }) async {
    await repository.resetPassword(
      token: token,
      password: password,
    );

    AnalyticsService.logEvent('password_reset_success');
  }
}
EOF

###############################################################################
# DATA – Response Model
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/models/reset_password_response_model.dart"
class ResetPasswordResponseModel {
  final bool success;

  ResetPasswordResponseModel({required this.success});

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] as bool,
    );
  }
}
EOF

###############################################################################
# DATA – Remote Datasource
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/datasources/reset_password_remote_datasource.dart"
import '../../../../../core/network/dio_client.dart';
import '../models/reset_password_response_model.dart';

class ResetPasswordRemoteDatasource {
  final DioClient dio;

  ResetPasswordRemoteDatasource(this.dio);

  Future<ResetPasswordResponseModel> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/reset-password',
      data: {
        'token': token,
        'password': password,
      },
    );

    return ResetPasswordResponseModel.fromJson(response.data!);
  }
}
EOF

###############################################################################
# DATA – Repository Implementation
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/repositories/reset_password_repository_impl.dart"
import '../../domain/entities/reset_password_entity.dart';
import '../../domain/repositories/reset_password_repository.dart';
import '../datasources/reset_password_remote_datasource.dart';

class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
  final ResetPasswordRemoteDatasource remote;

  ResetPasswordRepositoryImpl(this.remote);

  @override
  Future<ResetPasswordEntity> resetPassword({
    required String token,
    required String password,
  }) async {
    final result = await remote.resetPassword(
      token: token,
      password: password,
    );

    return ResetPasswordEntity(success: result.success);
  }
}
EOF

###############################################################################
# PRESENTATION – Reset Password Page
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/presentation/pages/reset_password_page.dart"
import 'package:flutter/material.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../../../../core/utils/validators/auth_validators.dart';
import '../../../../../core/utils/validators/string_validators.dart';
import '../../../../../core/utils/validators/validator_extensions.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../data/datasources/reset_password_remote_datasource.dart';
import '../../data/repositories/reset_password_repository_impl.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();

  late final ResetPasswordUseCase _useCase;

  @override
  void initState() {
    super.initState();
    _useCase = ResetPasswordUseCase(
      ResetPasswordRepositoryImpl(
        ResetPasswordRemoteDatasource(DioClient()),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _useCase.execute(
        token: widget.token,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful')),
      );
    } catch (e) {
      AppLogger.e('Reset password failed', e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) => [
                  (val) => StringValidators.required(val),
                  (val) => AuthValidators.password(val),
                ].validate(v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Reset Password feature created successfully."
