part of 'workflows_screen.dart';

class _FlowRecord {
  final String clientName;
  final String projectName;
  final String status;
  final int progress;
  final String dueDate;
  final List<WorkflowItem> items;

  const _FlowRecord({
    required this.clientName,
    required this.projectName,
    required this.status,
    required this.progress,
    required this.dueDate,
    required this.items,
  });

  int get stageIndex {
    var max = 0;
    for (final item in items) {
      final index = workflowStages.indexOf(item.stage);
      if (index > max) max = index;
    }
    return max;
  }

  String get currentStage => workflowStages[stageIndex];

  double get flowProgress {
    if (workflowStages.isEmpty) return 0;
    return ((stageIndex + 1) / workflowStages.length).clamp(0, 1).toDouble();
  }

  _FlowRecord copyWith({List<WorkflowItem>? items}) {
    return _FlowRecord(
      clientName: clientName,
      projectName: projectName,
      status: status,
      progress: progress,
      dueDate: dueDate,
      items: items ?? this.items,
    );
  }
}
