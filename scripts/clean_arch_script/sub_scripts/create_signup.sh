#!/bin/bash
set -e

echo "📝 Creating Signup feature (Clean Architecture)..."

# BASE_DIR must already be exported or set by master script
: "${BASE_DIR:?BASE_DIR is not set}"

FEATURE_DIR="$BASE_DIR/features/auth/signup"

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
cat << 'EOF' > "$FEATURE_DIR/domain/entities/signup_entity.dart"
class SignupEntity {
  final String accessToken;
  final String refreshToken;

  const SignupEntity({
    required this.accessToken,
    required this.refreshToken,
  });
}
EOF

###############################################################################
# DOMAIN – Repository Contract
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/repositories/signup_repository.dart"
import '../entities/signup_entity.dart';

abstract class SignupRepository {
  Future<SignupEntity> signup({
    required String name,
    required String email,
    required String password,
  });
}
EOF

###############################################################################
# DOMAIN – UseCase
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/domain/usecases/signup_usecase.dart"
import '../../../../../core/utils/firebase/analytics_service.dart';
import '../../../../../core/network/tokens/token_manager.dart';
import '../repositories/signup_repository.dart';

class SignupUseCase {
  final SignupRepository repository;

  SignupUseCase(this.repository);

  Future<void> execute({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await repository.signup(
      name: name,
      email: email,
      password: password,
    );

    await TokenManager.saveTokens(
      result.accessToken,
      result.refreshToken,
    );

    AnalyticsService.logEvent(
      'signup_success',
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
cat << 'EOF' > "$FEATURE_DIR/data/models/signup_response_model.dart"
class SignupResponseModel {
  final String accessToken;
  final String refreshToken;

  SignupResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
EOF

###############################################################################
# DATA – Remote Datasource
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/datasources/signup_remote_datasource.dart"
import '../../../../../core/network/dio_client.dart';
import '../models/signup_response_model.dart';

class SignupRemoteDatasource {
  final DioClient dio;

  SignupRemoteDatasource(this.dio);

  Future<SignupResponseModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return SignupResponseModel.fromJson(response.data!);
  }
}
EOF

###############################################################################
# DATA – Repository Implementation
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/data/repositories/signup_repository_impl.dart"
import '../../domain/entities/signup_entity.dart';
import '../../domain/repositories/signup_repository.dart';
import '../datasources/signup_remote_datasource.dart';

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDatasource remote;

  SignupRepositoryImpl(this.remote);

  @override
  Future<SignupEntity> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await remote.signup(
      name: name,
      email: email,
      password: password,
    );

    return SignupEntity(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
  }
}
EOF

###############################################################################
# PRESENTATION – Signup Page
###############################################################################
cat << 'EOF' > "$FEATURE_DIR/presentation/pages/signup_page.dart"
import 'package:flutter/material.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../../../../core/utils/validators/auth_validators.dart';
import '../../../../../core/utils/validators/string_validators.dart';
import '../../../../../core/utils/validators/validator_extensions.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../data/datasources/signup_remote_datasource.dart';
import '../../data/repositories/signup_repository_impl.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final SignupUseCase _signupUseCase;

  @override
  void initState() {
    super.initState();

    _signupUseCase = SignupUseCase(
      SignupRepositoryImpl(
        SignupRemoteDatasource(DioClient()),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _signupUseCase.execute(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful')),
      );
    } catch (e) {
      AppLogger.e('Signup failed', e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => [
                  (val) => StringValidators.required(val),
                ].validate(v),
              ),
              const SizedBox(height: 16),
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
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Signup feature created successfully."
