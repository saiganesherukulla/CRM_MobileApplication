part of 'crm_api.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String title;
  final String department;
  final String role;
  final String avatar;
  final String clientAccountId;
  final bool subscriptionActive;
  final bool passwordChangeRequired;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.department,
    required this.role,
    required this.avatar,
    required this.clientAccountId,
    required this.subscriptionActive,
    required this.passwordChangeRequired,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final name = _string(json['name'], 'User');
    return AuthUser(
      id: _string(json['id']),
      name: name,
      email: _string(json['email']),
      phone: _string(json['phone']),
      title: _string(json['title']),
      department: _string(json['department']),
      role: _string(json['role'], 'Employee'),
      avatar: _string(json['avatar'], _initials(name)),
      clientAccountId: _string(json['clientAccountId']),
      subscriptionActive: json['subscriptionActive'] == true,
      passwordChangeRequired: json['passwordChangeRequired'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'title': title,
        'department': department,
        'role': role,
        'avatar': avatar,
        'clientAccountId': clientAccountId,
        'subscriptionActive': subscriptionActive,
        'passwordChangeRequired': passwordChangeRequired,
      };
}
