part of 'workflows_screen.dart';

class _CreateWorkflowSheet extends StatefulWidget {
  final String? initialStage;
  final String? initialClientName;
  final String? initialTitle;

  const _CreateWorkflowSheet({
    this.initialStage,
    this.initialClientName,
    this.initialTitle,
  });

  @override
  State<_CreateWorkflowSheet> createState() => _CreateWorkflowSheetState();
}
