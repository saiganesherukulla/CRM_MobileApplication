part of 'models.dart';

class RoleInfo {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;

  const RoleInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      id: _string(json['id']),
      name: _string(json['name'], 'Role'),
      description: _string(json['description'], 'Custom role'),
      permissions: _stringList(json['permissions']),
    );
  }
}
