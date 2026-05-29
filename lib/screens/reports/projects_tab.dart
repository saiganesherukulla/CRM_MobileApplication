part of 'reports_screen.dart';

class _ProjectsTab extends StatelessWidget {
  final ReportSummary report;

  const _ProjectsTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final active =
        report.projects.where((project) => project.status == 'Active').length;
    final atRisk =
        report.projects.where((project) => project.status == 'At Risk').length;
    final completed = report.projects
        .where((project) => project.status == 'Completed')
        .length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChartCard(
          title: 'Project Status',
          subtitle: 'By count',
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                            value: active.toDouble(),
                            color: AppColors.primary,
                            title: '$active',
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: atRisk.toDouble(),
                            color: AppColors.error,
                            title: '$atRisk',
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: completed.toDouble(),
                            color: AppColors.success,
                            title: '$completed',
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                            radius: 50),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Legend(AppColors.primary, 'Active', '$active'),
                    const SizedBox(height: 10),
                    _Legend(AppColors.error, 'At Risk', '$atRisk'),
                    const SizedBox(height: 10),
                    _Legend(AppColors.success, 'Done', '$completed'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _TableCard(
          title: 'Project Progress',
          headers: const ['Project', 'Progress', 'Status', 'Due'],
          rows: report.projects
              .map((project) => [
                    _short(project.name, 18),
                    '${project.progress}%',
                    project.status,
                    project.dueDate
                  ])
              .toList(),
        ),
      ],
    );
  }
}
