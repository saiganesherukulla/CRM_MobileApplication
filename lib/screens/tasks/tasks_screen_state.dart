part of 'tasks_screen.dart';

class _TasksScreenState extends State<TasksScreen> {
  String _search = '';
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  late Future<List<CrmTask>> _future;

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.tasks();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.tasks();
    });
  }

  List<CrmTask> _filtered(List<CrmTask> tasks) {
    return tasks.where((task) {
      final matchStatus =
          _statusFilter == 'All' || task.status == _statusFilter;
      final matchPriority =
          _priorityFilter == 'All' || task.priority == _priorityFilter;
      final query = _search.toLowerCase();
      final matchSearch = task.title.toLowerCase().contains(query) ||
          task.client.toLowerCase().contains(query);
      return matchStatus && matchPriority && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Tasks',
        actions: [
          IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              onPressed: _showNewTaskSheet),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 18, color: AppColors.slate400),
                  ),
                ),
                const SizedBox(height: 10),
                _FilterRow(
                  label: 'Status',
                  values: const [
                    'All',
                    'New',
                    'In Progress',
                    'Review',
                    'Waiting for Client',
                    'Done'
                  ],
                  selected: _statusFilter,
                  onChanged: (value) => setState(() => _statusFilter = value),
                ),
                const SizedBox(height: 6),
                _FilterRow(
                  label: 'Priority',
                  values: const ['All', 'Critical', 'High', 'Medium', 'Low'],
                  selected: _priorityFilter,
                  dark: true,
                  onChanged: (value) => setState(() => _priorityFilter = value),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<CrmTask>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ApiLoading();
                }
                if (snapshot.hasError) {
                  return ApiErrorView(error: snapshot.error, onRetry: _reload);
                }
                final tasks = _filtered(snapshot.data ?? const []);
                if (tasks.isEmpty) return const ApiEmpty('No tasks found.');
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => _TaskCard(
                        task: tasks[index],
                        onTap: () => _showTaskDetail(tasks[index])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskDetail(CrmTask task) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskDetailSheet(task: task),
    );
    if (changed == true) _reload();
  }

  Future<void> _showNewTaskSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewTaskSheet(),
    );
    if (created == true) _reload();
  }
}
