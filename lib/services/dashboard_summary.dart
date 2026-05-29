part of 'crm_api.dart';

class DashboardSummary {
  final List<Map<String, dynamic>> metrics;
  final List<CrmTask> dueTasks;
  final List<ActivityItem> recentActivity;
  final List<Client> recentClients;
  final Map<String, dynamic> chartData;

  const DashboardSummary({
    required this.metrics,
    required this.dueTasks,
    required this.recentActivity,
    required this.recentClients,
    required this.chartData,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      metrics: _mapList(json['metrics']),
      dueTasks: _mapList(json['dueTasks']).map(CrmTask.fromJson).toList(),
      recentActivity:
          _mapList(json['recentActivity']).map(ActivityItem.fromJson).toList(),
      recentClients:
          _mapList(json['recentClients']).map(Client.fromJson).toList(),
      chartData: _map(json['chartData']),
    );
  }
}
