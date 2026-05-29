part of 'models.dart';

class EmailAccountInfo {
  final String id;
  final String userId;
  final String email;
  final String provider;
  final String status;
  final String lastSyncAt;
  final String lastSyncStatus;
  final String lastSyncMessage;

  const EmailAccountInfo({
    required this.id,
    required this.userId,
    required this.email,
    required this.provider,
    required this.status,
    required this.lastSyncAt,
    required this.lastSyncStatus,
    required this.lastSyncMessage,
  });

  factory EmailAccountInfo.fromJson(Map<String, dynamic> json) {
    return EmailAccountInfo(
      id: _string(json['id']),
      userId: _string(json['userId']),
      email: _string(json['email']),
      provider: _string(json['provider'], 'Email provider'),
      status: _string(json['status'], 'Disconnected'),
      lastSyncAt: _string(json['lastSyncAt']),
      lastSyncStatus: _string(json['lastSyncStatus']),
      lastSyncMessage: _string(json['lastSyncMessage']),
    );
  }
}
