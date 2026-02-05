import '../entities/login_entity.dart';

abstract class LoginRepository {
  Future<LoginEntity> execute({
    required String email,
    required String password,
  });
}
