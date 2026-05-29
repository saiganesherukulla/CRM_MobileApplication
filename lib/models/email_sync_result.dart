part of 'models.dart';

class EmailSyncResult {
  final String accountId;
  final String provider;
  final String status;
  final int imported;
  final String message;

  const EmailSyncResult({
    required this.accountId,
    required this.provider,
    required this.status,
    required this.imported,
    required this.message,
  });

  factory EmailSyncResult.fromJson(Map<String, dynamic> json) {
    return EmailSyncResult(
      accountId: _string(json['accountId']),
      provider: _string(json['provider']),
      status: _string(json['status']),
      imported: _int(json['imported']),
      message: _string(json['message'], 'Email sync completed'),
    );
  }
}
