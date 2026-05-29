part of 'workflows_screen.dart';

class _ClientFlowScreenState extends State<_ClientFlowScreen> {
  late Future<_FlowRecord> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRecord();
  }

  Future<_FlowRecord> _loadRecord() async {
    final grouped = await CrmApi.instance.workflowsByStage();
    final items = grouped.values
        .expand((stageItems) => stageItems)
        .where((item) => item.client == widget.record.clientName)
        .toList();
    return widget.record.copyWith(items: _uniqueFlowItems(items));
  }

  void _reload() {
    setState(() {
      _future = _loadRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: widget.record.clientName,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showNextStageSheet,
          ),
        ],
      ),
      body: FutureBuilder<_FlowRecord>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          final record = snapshot.data ?? widget.record;
          final stageCount =
              (record.stageIndex + 1).clamp(1, workflowStages.length).toInt();
          final visibleStages = workflowStages.take(stageCount).toList();
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FlowHeader(record: record),
                const SizedBox(height: 16),
                ...visibleStages.map((stage) {
                  final items = _uniqueFlowItems(
                      record.items.where((item) => item.stage == stage));
                  return _TimelineStage(
                    stage: stage,
                    items: items,
                    onAdd: () => _showCreateSheet(stage),
                    onEdit: _showEditSheet,
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showNextStageSheet() async {
    var record = widget.record;
    try {
      record = await _future;
    } catch (_) {
      record = widget.record;
    }
    await _showCreateSheet(_nextStageFor(record));
  }

  Future<void> _showCreateSheet([String? stage]) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateWorkflowSheet(
        initialStage: stage,
        initialClientName: widget.record.clientName,
        initialTitle: '${widget.record.projectName} update',
      ),
    );
    if (created == true) _reload();
  }

  Future<void> _showEditSheet(WorkflowItem item) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkflowEditorSheet(item: item),
    );
    if (changed == true) _reload();
  }

  String _nextStageFor(_FlowRecord record) {
    if (workflowStages.isEmpty) return '';
    if (record.items.isEmpty) return workflowStages.first;
    final index =
        (record.stageIndex + 1).clamp(0, workflowStages.length - 1).toInt();
    return workflowStages[index];
  }
}
