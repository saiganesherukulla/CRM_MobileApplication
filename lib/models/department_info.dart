part of 'models.dart';

class DepartmentInfo {
  final String id;
  final String name;
  final String head;
  final int members;

  const DepartmentInfo({
    required this.id,
    required this.name,
    required this.head,
    required this.members,
  });

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) {
    return DepartmentInfo(
      id: _string(json['id']),
      name: _string(json['name'], 'Department'),
      head: _string(json['head'], 'Unassigned'),
      members: _int(json['members']),
    );
  }
}
