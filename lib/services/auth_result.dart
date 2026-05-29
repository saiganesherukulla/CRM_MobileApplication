part of 'crm_api.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: _string(json['accessToken']),
      refreshToken: _string(json['refreshToken']),
      user: AuthUser.fromJson(_map(json['user'])),
    );
  }
}
