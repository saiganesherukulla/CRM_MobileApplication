part of 'reports_screen.dart';

class _WorkloadTab extends StatelessWidget {
  final ReportSummary report;

  const _WorkloadTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final rows = _mapList(report.chartData['workloadByEmployee']);
    final bars = rows.asMap().entries.map((entry) {
      return BarChartGroupData(x: entry.key, barRods: [
        BarChartRodData(
            toY: _number(entry.value['tasks']).toDouble(),
            color: AppColors.primary,
            width: 14,
            borderRadius: BorderRadius.circular(4))
      ]);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChartCard(
          title: 'Tasks by Team Member',
          subtitle: 'Active task count',
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: bars.isEmpty ? 5 : null,
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppColors.slate100, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
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
                        if (rows.isEmpty || value.toInt() >= rows.length) {
                          return const Text('');
                        }
                        return Text(
                            rows[value.toInt()]['name']
                                    ?.toString()
                                    .split(' ')
                                    .first ??
                                '',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.slate400));
                      },
                    ),
                  ),
                ),
                barGroups: bars,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _TableCard(
          title: 'Team Workload Summary',
          headers: const ['Name', 'Tasks', 'Done', 'Load'],
          rows: rows.map((row) {
            final tasks = _number(row['tasks']);
            return [
              row['name']?.toString() ?? 'Member',
              '$tasks',
              '${_number(row['completed'])}',
              tasks > 15 ? 'High' : 'Normal'
            ];
          }).toList(),
        ),
      ],
    );
  }
}
