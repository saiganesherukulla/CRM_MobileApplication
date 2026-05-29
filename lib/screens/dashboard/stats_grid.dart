part of 'dashboard_screen.dart';

class _StatsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;

  const _StatsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final visible = metrics.take(4).toList();
    if (visible.isEmpty) return const ApiEmpty('No KPI metrics yet.');
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.42,
      children: visible.map((metric) {
        final meta = _metricMeta(metric['label']?.toString() ?? '');
        return StatCard(
          title: metric['label']?.toString() ?? 'Metric',
          value: metric['value']?.toString() ?? '0',
          subtitle: metric['trend']?.toString(),
          icon: meta.icon,
          iconColor: meta.color,
          iconBg: meta.bg,
        );
      }).toList(),
    );
  }
}
