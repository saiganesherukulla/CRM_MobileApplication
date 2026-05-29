part of 'reports_screen.dart';

class _KpiCard extends StatelessWidget {
  final Map<String, dynamic> metric;

  const _KpiCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final tone = metric['tone']?.toString();
    final color = switch (tone) {
      'success' => AppColors.success,
      'warning' => AppColors.warning,
      'danger' => AppColors.error,
      'info' => AppColors.info,
      _ => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(metric['label']?.toString() ?? 'Metric',
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(metric['value']?.toString() ?? '0',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(metric['trend']?.toString() ?? '',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate400,
                  fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
