part of 'models.dart';

class ActivityItem {
  final String id;
  final String user;
  final String action;
  final String target;
  final String type;
  final String time;
  final String avatar;

  const ActivityItem({
    required this.id,
    required this.user,
    required this.action,
    required this.target,
    required this.type,
    required this.time,
    required this.avatar,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final user = _string(json['user'], 'System');
    return ActivityItem(
      id: _string(json['id']),
      user: user,
      action: _string(json['action'], 'updated'),
      target: _string(json['target'], 'record'),
      type: _string(json['type'], 'activity'),
      time: _date(json['time'] ?? json['createdAt']),
      avatar: _string(json['avatar'], _initials(user)),
    );
  }
}
