part of 'crm_api.dart';

class ClientSummary {
  final Client client;
  final List<Contact> contacts;
  final List<CrmTask> tasks;
  final List<Project> projects;
  final List<Ticket> tickets;
  final List<EmailMessage> emails;

  const ClientSummary({
    required this.client,
    required this.contacts,
    required this.tasks,
    required this.projects,
    required this.tickets,
    required this.emails,
  });

  factory ClientSummary.fromJson(Map<String, dynamic> json) {
    return ClientSummary(
      client: Client.fromJson(_map(json['client'])),
      contacts: _mapList(json['contacts']).map(Contact.fromJson).toList(),
      tasks: _mapList(json['tasks']).map(CrmTask.fromJson).toList(),
      projects: _mapList(json['projects']).map(Project.fromJson).toList(),
      tickets: _mapList(json['tickets']).map(Ticket.fromJson).toList(),
      emails: _mapList(json['emails']).map(EmailMessage.fromJson).toList(),
    );
  }
}
