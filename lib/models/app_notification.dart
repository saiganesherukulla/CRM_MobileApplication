part of 'models.dart';

class AppNotification {
  final String id;
  final String type;
  final String message;
  final String time;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.time,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _string(json['id']),
      type: _string(json['type'], 'info'),
      message: _string(json['message']),
      time: _date(json['time'] ?? json['createdAt']),
      read: json['read'] == true,
    );
  }
}
