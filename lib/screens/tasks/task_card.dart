part of 'tasks_screen.dart';

class _TaskCard extends StatelessWidget {
  final CrmTask task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: priorityColor(task.priority),
                        shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(task.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CrmAvatar(_initials(task.assignee), size: AvatarSize.xs),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(task.assignee,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6,
                    runSpacing: 4,
                    children: [CrmBadge(task.priority), CrmBadge(task.status)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 13, color: AppColors.slate400),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(task.client,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.slate400),
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text(task.due,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
