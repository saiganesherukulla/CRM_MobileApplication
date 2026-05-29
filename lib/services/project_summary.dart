part of 'crm_api.dart';

class ProjectSummary {
  final Project project;
  final List<CrmTask> tasks;

  const ProjectSummary({required this.project, required this.tasks});

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    return ProjectSummary(
      project: Project.fromJson(_map(json['project'])),
      tasks: _mapList(json['tasks']).map(CrmTask.fromJson).toList(),
    );
  }
}
