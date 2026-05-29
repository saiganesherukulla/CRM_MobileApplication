part of 'reports_screen.dart';

class _OverviewTab extends StatelessWidget {
  final ReportSummary report;

  const _OverviewTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final canViewFinancials = CrmApi.instance.canViewFinancials();
    final revenueRows = _mapList(report.chartData['revenueByClient']);
    final spots = revenueRows.isEmpty
        ? [const FlSpot(0, 0)]
        : revenueRows
            .asMap()
            .entries
            .map((entry) => FlSpot(
                entry.key.toDouble(), _number(entry.value['value']).toDouble()))
            .toList();
    final healthRows = _mapList(report.chartData['clientHealth']);
    final active = _valueFor(healthRows, 'Active');
    final atRisk = _valueFor(healthRows, 'At Risk');
    final inactive = _valueFor(healthRows, 'Inactive');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children:
              report.metrics.map((metric) => _KpiCard(metric: metric)).toList(),
        ),
        if (canViewFinancials) ...[
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Client Service Value',
            subtitle: 'Visible only to Super Admin and Founder',
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: AppColors.slate100, strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value != value.roundToDouble()) {
                            return const Text('');
                          }
                          if (revenueRows.isEmpty ||
                              value.toInt() >= revenueRows.length) {
                            return const Text('');
                          }
                          return Text(
                              revenueRows[value.toInt()]['name']?.toString() ??
                                  '',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.slate400));
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Client Health Distribution',
          subtitle: 'Current snapshot',
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
                            color: AppColors.success,
                            title: '$active',
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: atRisk.toDouble(),
                            color: AppColors.warning,
                            title: '$atRisk',
                            titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                            radius: 50),
                        PieChartSectionData(
                            value: inactive.toDouble(),
                            color: AppColors.error,
                            title: '$inactive',
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
                    _Legend(AppColors.success, 'Healthy', '$active'),
                    const SizedBox(height: 10),
                    _Legend(AppColors.warning, 'At Risk', '$atRisk'),
                    const SizedBox(height: 10),
                    _Legend(AppColors.error, 'Inactive', '$inactive'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
