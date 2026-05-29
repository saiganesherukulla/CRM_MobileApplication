part of 'reports_screen.dart';

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<_LegendItem>? legendItems;

  const _ChartCard(
      {required this.title,
      required this.subtitle,
      required this.child,
      this.legendItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (legendItems != null) ...[
            const SizedBox(height: 8),
            Wrap(
                spacing: 16,
                runSpacing: 8,
                children: legendItems!
                    .map((item) =>
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 5),
                          Text(item.label,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.slate500))
                        ]))
                    .toList()),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
