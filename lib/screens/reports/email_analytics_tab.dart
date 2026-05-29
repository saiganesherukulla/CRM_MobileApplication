part of 'reports_screen.dart';

class _EmailAnalyticsTab extends StatelessWidget {
  final ReportSummary report;

  const _EmailAnalyticsTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final rows = _mapList(report.chartData['emailActivity']);
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
    final sentCount =
        report.emails.where((email) => email.direction == 'outbound').length;
    final receivedCount =
        report.emails.where((email) => email.direction == 'inbound').length;
    final byClient = <String, List<EmailMessage>>{};
    for (final email in report.emails) {
      byClient.putIfAbsent(email.client, () => []).add(email);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _SmallStat('Total Sent', '$sentCount', AppColors.primary),
            _SmallStat('Received', '$receivedCount', AppColors.info),
            _SmallStat(
                'Queued',
                '${report.emails.where((email) => email.status == 'Queued').length}',
                AppColors.success),
            _SmallStat(
                'Unread',
                '${report.emails.where((email) => email.unread).length}',
                AppColors.warning),
          ],
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: 'Email Activity',
          subtitle: 'Sent vs received',
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
                          getTitlesWidget: (value, _) => Text(
                              rows.isNotEmpty &&
                                      value == value.roundToDouble() &&
                                      value.toInt() < rows.length
                                  ? rows[value.toInt()]['month']?.toString() ??
                                      ''
                                  : '',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.slate400)),
                          interval: 1)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                      spots: sent,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true)),
                  LineChartBarData(
                      spots: received,
                      isCurved: true,
                      color: AppColors.info,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true)),
                ],
              ),
            ),
          ),
          legendItems: const [
            _LegendItem(AppColors.primary, 'Sent'),
            _LegendItem(AppColors.info, 'Received')
          ],
        ),
        const SizedBox(height: 16),
        _TableCard(
          title: 'Top Clients by Email Volume',
          headers: const ['Client', 'Sent', 'Received', 'Total'],
          rows: byClient.entries.take(5).map((entry) {
            final sentForClient = entry.value
                .where((email) => email.direction == 'outbound')
                .length;
            final receivedForClient = entry.value.length - sentForClient;
            return [
              entry.key,
              '$sentForClient',
              '$receivedForClient',
              '${entry.value.length}'
            ];
          }).toList(),
        ),
      ],
    );
  }
}
