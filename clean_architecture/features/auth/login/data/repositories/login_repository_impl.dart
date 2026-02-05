import '../../domain/entities/login_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDatasource remote;

  LoginRepositoryImpl(this.remote);

  @override
  Future<LoginEntity> execute({
    required String email,
    required String password,
  }) async {
    final result = await remote.execute(
      email: email,
      password: password,
    );

    return LoginEntity(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
  }
}
