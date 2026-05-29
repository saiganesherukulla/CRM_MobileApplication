part of 'models.dart';

class TeamMember {
  final String id;
  final String name;
  final String initials;
  final String role;
  final String department;
  final String title;
  final String phone;
  final String status;
  final int tasks;
  final String email;

  String get avatar => initials;

  const TeamMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.department,
    required this.title,
    required this.phone,
    required this.status,
    required this.tasks,
    required this.email,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final name = _string(json['name'], 'Team member');
    return TeamMember(
      id: _string(json['id']),
      name: name,
      initials: _string(json['avatar'], _initials(name)),
      role: _string(json['role'], 'Employee'),
      department: _string(json['department'], 'General'),
      title: _string(json['title']),
      phone: _string(json['phone']),
      status: _string(json['status'], 'Active'),
      tasks: _int(json['tasks']),
      email: _string(json['email']),
    );
  }
}
