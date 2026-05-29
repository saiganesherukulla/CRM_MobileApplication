part of 'reports_screen.dart';

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Overview',
    'Emails',
    'Workload',
    'Projects',
    'Tickets'
  ];

  late TabController _tabCtrl;
  late Future<ReportSummary> _future;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _future = CrmApi.instance.reports();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.reports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(
        title: 'Reports',
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: _reload)
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.slate500,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: FutureBuilder<ReportSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final report = snapshot.data;
          if (report == null) {
            return const ApiEmpty('No report data available.');
          }
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _OverviewTab(report: report),
              _EmailAnalyticsTab(report: report),
              _WorkloadTab(report: report),
              _ProjectsTab(report: report),
              _TicketsTab(report: report),
            ],
          );
        },
      ),
    );
  }
}
