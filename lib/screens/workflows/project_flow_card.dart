part of 'workflows_screen.dart';

class _ProjectFlowCard extends StatelessWidget {
  final _FlowRecord record;
  final VoidCallback onTap;

  const _ProjectFlowCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _stageHeaderColor(record.currentStage);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CrmAvatar(_initials(record.clientName), size: AvatarSize.md),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.clientName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(record.projectName,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.slate300),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: record.flowProgress,
                      minHeight: 6,
                      backgroundColor: AppColors.slate100,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(record.flowProgress * 100).round()}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniPill(record.currentStage, color),
                _MiniPill('${record.items.length} flow items', AppColors.info),
                _MiniPill(record.status, AppColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
