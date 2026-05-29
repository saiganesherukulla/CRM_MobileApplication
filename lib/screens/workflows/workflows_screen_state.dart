part of 'workflows_screen.dart';

class _WorkflowsScreenState extends State<WorkflowsScreen> {
  late Future<_WorkflowData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_WorkflowData> _loadData() async {
    final grouped = await CrmApi.instance.workflowsByStage();
    var projects = const <Project>[];
    try {
      projects = await CrmApi.instance.projects();
    } catch (_) {
      projects = const <Project>[];
    }
    return _WorkflowData(projects: projects, grouped: grouped);
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'CRM Flow',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => _showCreateSheet(),
          ),
        ],
      ),
      body: FutureBuilder<_WorkflowData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final records = _recordsFrom(snapshot.data ?? _WorkflowData.empty());
          if (records.isEmpty) {
            return const ApiEmpty(
                'No project flows yet. Add a workflow item to begin.');
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _FlowIntro();
                }
                final record = records[index - 1];
                return _ProjectFlowCard(
                  record: record,
                  onTap: () => _openRecord(record),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<_FlowRecord> _recordsFrom(_WorkflowData data) {
    final items = _uniqueFlowItems(data.items);
    final byClient = <String, List<WorkflowItem>>{};
    for (final item in items) {
      byClient.putIfAbsent(item.client, () => []).add(item);
    }

    final records = <_FlowRecord>[];
    final seenClients = <String>{};
    for (final project in data.projects) {
      final client = project.client;
      seenClients.add(client);
      records.add(_FlowRecord(
        clientName: client,
        projectName: project.name,
        status: project.status,
        progress: project.progress,
        dueDate: project.dueDate,
        items: byClient[client] ?? const [],
      ));
    }

    for (final entry in byClient.entries) {
      if (seenClients.contains(entry.key)) continue;
      records.add(_FlowRecord(
        clientName: entry.key,
        projectName: 'General CRM Flow',
        status: 'Active',
        progress: _progressFor(entry.value),
        dueDate: _latestDue(entry.value),
        items: entry.value,
      ));
    }

    records.sort((a, b) => b.stageIndex.compareTo(a.stageIndex));
    return records;
  }

  void _openRecord(_FlowRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ClientFlowScreen(record: record),
      ),
    ).then((_) => _reload());
  }

  Future<void> _showCreateSheet([String? stage, _FlowRecord? record]) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateWorkflowSheet(
        initialStage: stage,
        initialClientName: record?.clientName,
        initialTitle: record == null ? null : '${record.projectName} update',
      ),
    );
    if (created == true) _reload();
  }
}
