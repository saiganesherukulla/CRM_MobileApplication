part of 'projects_screen.dart';

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _search = '';
  String _statusFilter = 'All';
  bool _gridView = true;
  late Future<List<Project>> _future;

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.projects();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.projects();
    });
  }

  List<Project> _filtered(List<Project> projects) {
    return projects.where((project) {
      final matchStatus =
          _statusFilter == 'All' || project.status == _statusFilter;
      final query = _search.toLowerCase();
      final matchSearch =
          project.name.toLowerCase().contains(query) ||
          project.client.toLowerCase().contains(query);
      return matchStatus && matchSearch;
    }).toList();
  }

  Color _progressColor(Project project) {
    if (project.status == 'Completed') return AppColors.success;
    if (project.status == 'At Risk') return AppColors.error;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Projects',
        actions: [
          IconButton(
            icon: Icon(
              _gridView ? Icons.list_rounded : Icons.grid_view_rounded,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _gridView = !_gridView),
          ),
          if (!CrmApi.instance.isClientUser)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              onPressed: _showNewProjectSheet,
            ),
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
                    hintText: 'Search projects...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'All',
                          'Active',
                          'At Risk',
                          'On Hold',
                          'Completed',
                        ].map((status) {
                          final selected = _statusFilter == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _statusFilter = status),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.slate100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.slate600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ApiLoading();
                }
                if (snapshot.hasError) {
                  return ApiErrorView(error: snapshot.error, onRetry: _reload);
                }
                final projects = _filtered(snapshot.data ?? const []);
                if (projects.isEmpty) {
                  return const ApiEmpty('No projects found.');
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _reload(),
                  child: _gridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.78,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: projects.length,
                          itemBuilder: (_, index) => _ProjectGridCard(
                            project: projects[index],
                            progressColor: _progressColor(projects[index]),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: projects.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, index) => _ProjectListCard(
                            project: projects[index],
                            progressColor: _progressColor(projects[index]),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewProjectSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewProjectSheet(),
    );
    if (created == true) _reload();
  }
}
