part of 'workflows_screen.dart';

class _WorkflowCard extends StatelessWidget {
  final WorkflowItem item;
  final VoidCallback onTap;

  const _WorkflowCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priority = priorityColor(item.priority);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: item.tags.map((tag) => _Tag(tag)).toList(),
              ),
            if (item.tags.isNotEmpty) const SizedBox(height: 8),
            Text(item.title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                CrmAvatar(_initials(item.assignee), size: AvatarSize.xs),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(item.assignee,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                _MiniPill(item.priority, priority),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined,
                    size: 15, color: AppColors.slate400),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text(item.due,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate400)),
                const SizedBox(width: 12),
                const Icon(Icons.description_outlined,
                    size: 12, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text('${item.documents.length}',
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
