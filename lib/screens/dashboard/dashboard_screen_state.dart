part of 'dashboard_screen.dart';

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;
  late Future<List<AppNotification>> _notifications;

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.dashboard();
    _notifications = CrmApi.instance.notifications();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.dashboard();
      _notifications = CrmApi.instance.notifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = CrmApi.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, ${user?.name.split(' ').first ?? 'there'}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Text("Here's what's happening today",
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        toolbarHeight: 60,
        actions: [
          FutureBuilder<List<AppNotification>>(
            future: _notifications,
            builder: (context, snapshot) {
              final unread = (snapshot.data ?? const <AppNotification>[])
                  .where((item) => !item.read)
                  .length;
              return Stack(
                children: [
                  IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.slate600),
                      onPressed: _reload),
                  if (unread > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.error, shape: BoxShape.circle)),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CrmAvatar(user?.avatar ?? 'NA', size: AvatarSize.md),
          ),
        ],
      ),
      body: FutureBuilder<DashboardSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final data = snapshot.data;
          if (data == null) {
            return const ApiEmpty('Dashboard data is not available.');
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatsGrid(metrics: data.metrics),
                const SizedBox(height: 16),
                _EmailActivityChart(chartData: data.chartData),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Upcoming Tasks',
                  trailing: TextButton(
                    onPressed: () => context.go('/tasks'),
                    child: const Text('View all',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
                  padding: EdgeInsets.zero,
                  child: data.dueTasks.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No open tasks yet.',
                              style: TextStyle(color: AppColors.slate400)))
                      : Column(
                          children: data.dueTasks
                              .map((task) => _TaskTile(task: task))
                              .toList()),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Recent Activity',
                  padding: EdgeInsets.zero,
                  child: data.recentActivity.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No recent activity.',
                              style: TextStyle(color: AppColors.slate400)))
                      : Column(
                          children: data.recentActivity
                              .map((item) => _ActivityTile(item: item))
                              .toList()),
                ),
                const SizedBox(height: 16),
                _ClientHealthChart(chartData: data.chartData),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
