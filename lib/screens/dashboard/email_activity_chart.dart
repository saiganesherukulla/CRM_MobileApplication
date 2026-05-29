part of 'dashboard_screen.dart';

class _EmailActivityChart extends StatelessWidget {
  final Map<String, dynamic> chartData;

  const _EmailActivityChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    final rows = _mapList(chartData['emailActivity']);
    final sent = rows.isEmpty
        ? [const FlSpot(0, 0)]
        : rows
            .asMap()
            .entries
            .map((entry) => FlSpot(
                entry.key.toDouble(), _number(entry.value['sent']).toDouble()))
            .toList();
    final received = rows.isEmpty
        ? [const FlSpot(0, 0)]
        : rows
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(),
                _number(entry.value['received']).toDouble()))
            .toList();
    return SectionCard(
      title: 'Email Activity',
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
                    return Text(rows[value.toInt()]['month']?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.slate400));
                  },
                  reservedSize: 22,
                ),
              ),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.slate400)))),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              _lineBar(sent, AppColors.primaryLight),
              _lineBar(received, AppColors.success),
            ],
          ),
        ),
      ),
    );
  }

  LineChartBarData _lineBar(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.08)),
    );
  }
}
