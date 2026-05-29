part of 'reports_screen.dart';

class _TicketsTab extends StatelessWidget {
  final ReportSummary report;

  const _TicketsTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final rows = _mapList(report.chartData['ticketsByPriority']);
    final bars = rows.asMap().entries.map((entry) {
      final value = _number(entry.value['value']);
      final color = switch (entry.value['name']?.toString()) {
        'Critical' => AppColors.error,
        'High' => AppColors.warning,
        'Low' => AppColors.success,
        _ => AppColors.info,
      };
      return BarChartGroupData(x: entry.key, barRods: [
        BarChartRodData(
            toY: value.toDouble(),
            color: color,
            width: 18,
            borderRadius: BorderRadius.circular(4))
      ]);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChartCard(
          title: 'Tickets by Priority',
          subtitle: 'Current support load',
          child: SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
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
                          getTitlesWidget: (value, _) => Text(
                              rows.isNotEmpty &&
                                      value == value.roundToDouble() &&
                                      value.toInt() < rows.length
                                  ? rows[value.toInt()]['name']?.toString() ??
                                      ''
                                  : '',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.slate400)))),
                ),
                barGroups: bars,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _TableCard(
          title: 'Recent Tickets',
          headers: const ['ID', 'Title', 'Priority', 'SLA'],
          rows: report.tickets
              .map((ticket) => [
                    ticket.ticketNumber,
                    _short(ticket.title, 20),
                    ticket.priority,
                    ticket.sla
                  ])
              .toList(),
        ),
      ],
    );
  }
}
