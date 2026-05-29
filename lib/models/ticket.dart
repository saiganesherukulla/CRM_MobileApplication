part of 'models.dart';

class Ticket {
  final String id;
  final String ticketNumber;
  final String clientId;
  final String client;
  final String title;
  final String priority;
  final String status;
  final String assigneeId;
  final String assignee;
  final String sla;
  final String created;
  final String updated;
  final String category;
  final String resolutionNotes;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.clientId,
    required this.client,
    required this.title,
    required this.priority,
    required this.status,
    required this.assigneeId,
    required this.assignee,
    required this.sla,
    required this.created,
    required this.updated,
    required this.category,
    required this.resolutionNotes,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final id = _string(json['id'], _string(json['ticketNumber']));
    return Ticket(
      id: id,
      ticketNumber: _string(json['ticketNumber'], id),
      clientId: _string(json['clientId']),
      client: _string(json['client'], 'No client'),
      title: _string(json['title'], 'Untitled ticket'),
      priority: _string(json['priority'], 'Medium'),
      status: _string(json['status'], 'Open'),
      assigneeId: _string(json['assigneeId']),
      assignee: _string(json['assignee'], 'Unassigned'),
      sla: _string(json['sla'], 'On Track'),
      created: _date(json['created'] ?? json['createdAt']),
      updated: _date(json['updated'] ?? json['updatedAt']),
      category: _string(json['category'], _string(json['priority'], 'General')),
      resolutionNotes: _string(json['resolutionNotes']),
    );
  }
}
