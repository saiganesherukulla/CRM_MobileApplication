part of 'dashboard_screen.dart';

class _ClientHealthChart extends StatelessWidget {
  final Map<String, dynamic> chartData;

  const _ClientHealthChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    final rows = _mapList(chartData['clientHealth']);
    final active = _valueFor(rows, 'Active');
    final atRisk = _valueFor(rows, 'At Risk');
    final inactive = _valueFor(rows, 'Inactive');
    final total = active + atRisk + inactive;
    return SectionCard(
      title: 'Client Health',
      child: total == 0
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: Text('No client health data yet.',
                      style: TextStyle(color: AppColors.slate400))))
          : Column(
              children: [
                SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                            value: active.toDouble(),
                            color: AppColors.success,
                            title: '$active',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                            radius: 55),
                        PieChartSectionData(
                            value: atRisk.toDouble(),
                            color: AppColors.warning,
                            title: '$atRisk',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                            radius: 55),
                        PieChartSectionData(
                            value: inactive.toDouble(),
                            color: AppColors.error,
                            title: '$inactive',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                            radius: 55),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _Legend('Active', AppColors.success),
                    _Legend('At Risk', AppColors.warning),
                    _Legend('Inactive', AppColors.error),
                  ],
                ),
              ],
            ),
    );
  }
}
