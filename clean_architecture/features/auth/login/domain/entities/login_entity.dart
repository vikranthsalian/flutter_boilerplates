class LoginEntity {
  final String accessToken;
  final String refreshToken;

  const LoginEntity({
    required this.accessToken,
    required this.refreshToken,
  });
}
