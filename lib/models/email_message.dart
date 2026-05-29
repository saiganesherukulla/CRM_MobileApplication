part of 'models.dart';

class EmailMessage {
  final String id;
  final String from;
  final String fromEmail;
  final String client;
  final String subject;
  final String preview;
  final String time;
  final bool unread;
  final String status;
  final String direction;
  final int thread;
  final String body;

  const EmailMessage({
    required this.id,
    required this.from,
    required this.fromEmail,
    required this.client,
    required this.subject,
    required this.preview,
    required this.time,
    required this.unread,
    required this.status,
    required this.direction,
    required this.thread,
    required this.body,
  });

  factory EmailMessage.fromJson(Map<String, dynamic> json) {
    return EmailMessage(
      id: _string(json['id']),
      from: _string(json['from'], _string(json['fromEmail'], 'Unknown sender')),
      fromEmail: _string(json['fromEmail']),
      client: _string(json['client'], 'No client'),
      subject: _string(json['subject'], '(No subject)'),
      preview: _string(json['preview'], _string(json['body'])),
      time: _date(json['time'] ?? json['createdAt']),
      unread: json['unread'] == true,
      status: _string(json['status'], 'Draft'),
      direction: _string(json['direction'], 'outbound'),
      thread: _int(json['thread'], 1),
      body: _string(json['body']),
    );
  }
}
