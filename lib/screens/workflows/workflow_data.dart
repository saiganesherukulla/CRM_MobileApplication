part of 'workflows_screen.dart';

class _WorkflowData {
  final List<Project> projects;
  final Map<String, List<WorkflowItem>> grouped;

  const _WorkflowData({required this.projects, required this.grouped});

  factory _WorkflowData.empty() =>
      const _WorkflowData(projects: [], grouped: {});

  List<WorkflowItem> get items =>
      grouped.values.expand((stageItems) => stageItems).toList();
}
