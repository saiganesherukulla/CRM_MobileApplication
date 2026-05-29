part of 'crm_api.dart';

class ReportSummary {
  final List<Map<String, dynamic>> metrics;
  final Map<String, dynamic> chartData;
  final List<Client> clients;
  final List<Project> projects;
  final List<CrmTask> tasks;
  final List<Ticket> tickets;
  final List<EmailMessage> emails;

  const ReportSummary({
    required this.metrics,
    required this.chartData,
    required this.clients,
    required this.projects,
    required this.tasks,
    required this.tickets,
    required this.emails,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      metrics: _mapList(json['metrics']),
      chartData: _map(json['chartData']),
      clients: _mapList(json['clients']).map(Client.fromJson).toList(),
      projects: _mapList(json['projects']).map(Project.fromJson).toList(),
      tasks: _mapList(json['tasks']).map(CrmTask.fromJson).toList(),
      tickets: _mapList(json['tickets']).map(Ticket.fromJson).toList(),
      emails: _mapList(json['emails']).map(EmailMessage.fromJson).toList(),
    );
  }
}
