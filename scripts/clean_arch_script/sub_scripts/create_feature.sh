#!/bin/bash
set -e

echo "🚀 Auth Feature Generator (Clean Architecture)"
echo "---------------------------------------------"

read -p "👉 Enter feature path (relative to $BASE_DIR/features/, e.g. auth/signup): " FEATURE_PATH


# Ask user for feature name
read -p "👉 Enter feature name (e.g. login, signup, forgot_password): " FEATURE_NAME

if [ -z "$FEATURE_NAME" ]; then
  echo "❌ Feature name cannot be empty."
  exit 1
fi



# Paths
BASE_DIR="$BASE_DIR/features/$FEATURE_PATH/$FEATURE_NAME"


# snake_case → PascalCase (forgot_password → ForgotPassword)
CLASS_NAME=$(echo "$FEATURE_NAME" | awk -F_ '{
  for (i=1; i<=NF; i++) {
    printf toupper(substr($i,1,1)) substr($i,2)
  }
}')

# snake_case → kebab-case (forgot_password → forgot-password)
API_NAME=$(echo "$FEATURE_NAME" | tr '_' '-')

echo ""
echo "📦 Creating $FEATURE_NAME Feature"
echo "   • Feature Name : $FEATURE_NAME"
echo "   • Class Prefix : $CLASS_NAME"
echo "   • Directory : $BASE_DIR"
echo ""

# Create folder structure
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
cat << EOF > $BASE_DIR/domain/entities/${FEATURE_NAME}_entity.dart
class ${CLASS_NAME}Entity {
  final String accessToken;
  final String refreshToken;

  const ${CLASS_NAME}Entity({
    required this.accessToken,
    required this.refreshToken,
  });
}
EOF

###############################################################################
# DOMAIN – Repository Contract
###############################################################################
cat << EOF > $BASE_DIR/domain/repositories/${FEATURE_NAME}_repository.dart
import '../entities/${FEATURE_NAME}_entity.dart';

abstract class ${CLASS_NAME}Repository {
  Future<${CLASS_NAME}Entity> execute({
    required String email,
    required String password,
  });
}
EOF

###############################################################################
# DOMAIN – UseCase
###############################################################################
cat << EOF > $BASE_DIR/domain/usecases/${FEATURE_NAME}_usecase.dart
import '../../../../../core/utils/firebase/analytics_service.dart';
import '../../../../../core/core/network/tokens/token_manager.dart';
import '../repositories/${FEATURE_NAME}_repository.dart';

class ${CLASS_NAME}UseCase {
  final ${CLASS_NAME}Repository repository;

  ${CLASS_NAME}UseCase(this.repository);

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
      '${FEATURE_NAME}_success',
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
cat << EOF > $BASE_DIR/data/models/${FEATURE_NAME}_response_model.dart
class ${CLASS_NAME}ResponseModel {
  final String accessToken;
  final String refreshToken;

  ${CLASS_NAME}ResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory ${CLASS_NAME}ResponseModel.fromJson(Map<String, dynamic> json) {
    return ${CLASS_NAME}ResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
EOF

###############################################################################
# DATA – Remote Datasource
###############################################################################
cat << EOF > $BASE_DIR/data/datasources/${FEATURE_NAME}_remote_datasource.dart
import '../../../../../core/utils/firebase/crashlytics_service.dart';
import '../../../../../core/core/network/dio_client.dart';
import '../models/${FEATURE_NAME}_response_model.dart';

class ${CLASS_NAME}RemoteDatasource {
  final DioClient dio;

  ${CLASS_NAME}RemoteDatasource(this.dio);

  Future<${CLASS_NAME}ResponseModel> execute({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/$API_NAME',
        data: {
          'email': email,
          'password': password,
        },
      );

      return ${CLASS_NAME}ResponseModel.fromJson(response.data!);
    } catch (e, s) {
      CrashlyticsService.recordError(e, s);
      rethrow;
    }
  }
}
EOF

###############################################################################
# DATA – Repository Implementation
###############################################################################
cat << EOF > $BASE_DIR/data/repositories/${FEATURE_NAME}_repository_impl.dart
import '../../domain/entities/${FEATURE_NAME}_entity.dart';
import '../../domain/repositories/${FEATURE_NAME}_repository.dart';
import '../datasources/${FEATURE_NAME}_remote_datasource.dart';

class ${CLASS_NAME}RepositoryImpl implements ${CLASS_NAME}Repository {
  final ${CLASS_NAME}RemoteDatasource remote;

  ${CLASS_NAME}RepositoryImpl(this.remote);

  @override
  Future<${CLASS_NAME}Entity> execute({
    required String email,
    required String password,
  }) async {
    final result = await remote.execute(
      email: email,
      password: password,
    );

    return ${CLASS_NAME}Entity(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
  }
}
EOF

###############################################################################
# PRESENTATION – Page
###############################################################################
cat << EOF > $BASE_DIR/presentation/pages/${FEATURE_NAME}_page.dart
import 'package:flutter/material.dart';
import '../../../../../core/core/network/dio_client.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../../../../core/utils/validators/auth_validators.dart';
import '../../../../../core/utils/validators/string_validators.dart';
import '../../../../../core/utils/validators/validator_extensions.dart';
import '../../domain/usecases/${FEATURE_NAME}_usecase.dart';
import '../../data/datasources/${FEATURE_NAME}_remote_datasource.dart';
import '../../data/repositories/${FEATURE_NAME}_repository_impl.dart';

class ${CLASS_NAME}Page extends StatefulWidget {
  const ${CLASS_NAME}Page({super.key});

  @override
  State<${CLASS_NAME}Page> createState() => _${CLASS_NAME}PageState();
}

class _${CLASS_NAME}PageState extends State<${CLASS_NAME}Page> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final ${CLASS_NAME}UseCase _useCase;

  @override
  void initState() {
    super.initState();

    _useCase = ${CLASS_NAME}UseCase(
      ${CLASS_NAME}RepositoryImpl(
        ${CLASS_NAME}RemoteDatasource(DioClient()),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _useCase.execute(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$CLASS_NAME successful')),
      );
    } catch (e) {
      AppLogger.e('$CLASS_NAME failed', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$CLASS_NAME failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$CLASS_NAME')),
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
                child: Text('$CLASS_NAME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo ""
echo "✅ Auth feature '$FEATURE_NAME' created successfully at $BASE_DIR"
