part of 'crm_api.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatar;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final name = _string(json['name'], 'User');
    return AuthUser(
      id: _string(json['id']),
      name: name,
      email: _string(json['email']),
      role: _string(json['role'], 'Employee'),
      avatar: _string(json['avatar'], _initials(name)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar': avatar,
      };
}
