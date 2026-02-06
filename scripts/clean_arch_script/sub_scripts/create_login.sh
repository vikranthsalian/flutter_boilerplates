#!/bin/bash
set -e

echo "🔐 Creating Login feature (Clean Architecture)..."

BASE_DIR="$BASE_DIR/features/auth/login"

mkdir -p \
  $BASE_DIR/data/datasources \
  $BASE_DIR/data/models \
  $BASE_DIR/data/repositories \
  $BASE_DIR/domain/entities \
  $BASE_DIR/domain/repositories \
  $BASE_DIR/domain/usecases \
  $BASE_DIR/presentation/pages

###############################################################################
# DOMAIN – Entity
###############################################################################
cat << 'EOF' > $BASE_DIR/domain/entities/login_entity.dart
class LoginEntity {
  final String accessToken;
  final String refreshToken;

  const LoginEntity({
    required this.accessToken,
    required this.refreshToken,
  });
}
EOF

###############################################################################
# DOMAIN – Repository Contract
###############################################################################
cat << 'EOF' > $BASE_DIR/domain/repositories/login_repository.dart
import '../entities/login_entity.dart';

abstract class LoginRepository {
  Future<LoginEntity> login({
    required String email,
    required String password,
  });
}
EOF

###############################################################################
# DOMAIN – UseCase
###############################################################################
cat << 'EOF' > $BASE_DIR/domain/usecases/login_usecase.dart
import '../../../../../core/utils/firebase/analytics_service.dart';
import '../../../../../core/network/tokens/token_manager.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<void> execute({
    required String email,
    required String password,
  }) async {
    final result = await repository.login(
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
EOF

###############################################################################
# DATA – Response Model
###############################################################################
cat << 'EOF' > $BASE_DIR/data/models/login_response_model.dart
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
EOF

###############################################################################
# DATA – Remote Datasource
###############################################################################
cat << 'EOF' > $BASE_DIR/data/datasources/login_remote_datasource.dart
import '../../../../../core/network/dio_client.dart';
import '../models/login_response_model.dart';

class LoginRemoteDatasource {
  final DioClient dio;

  LoginRemoteDatasource(this.dio);

  Future<LoginResponseModel> login({
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
      rethrow;
    }
  }
}
EOF

###############################################################################
# DATA – Repository Implementation
###############################################################################
cat << 'EOF' > $BASE_DIR/data/repositories/login_repository_impl.dart
import '../../domain/entities/login_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDatasource remote;

  LoginRepositoryImpl(this.remote);

  @override
  Future<LoginEntity> login({
    required String email,
    required String password,
  }) async {
    final result = await remote.login(
      email: email,
      password: password,
    );

    return LoginEntity(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
  }
}
EOF

###############################################################################
# PRESENTATION – Login Page
###############################################################################
cat << 'EOF' > $BASE_DIR/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../../../../core/utils/validators/auth_validators.dart';
import '../../../../../core/utils/validators/string_validators.dart';
import '../../../../../core/utils/validators/validator_extensions.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../../data/repositories/login_repository_impl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final LoginUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();

    _loginUseCase = LoginUseCase(
      LoginRepositoryImpl(
        LoginRemoteDatasource(DioClient()),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _loginUseCase.execute(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
    } catch (e) {
      AppLogger.e('Login failed', e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => [
                  (val) => StringValidators.required(val),
                  (val) => AuthValidators.password(val),
                ].validate(v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Login feature created successfully."

