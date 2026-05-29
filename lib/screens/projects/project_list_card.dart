part of 'projects_screen.dart';

class _ProjectListCard extends StatelessWidget {
  final Project project;
  final Color progressColor;

  const _ProjectListCard({required this.project, required this.progressColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(projectId: project.id))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.folder_rounded,
                        color: progressColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(project.client,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                CrmBadge(project.status),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                          value: project.progress / 100,
                          backgroundColor: AppColors.slate100,
                          valueColor: AlwaysStoppedAnimation(progressColor),
                          minHeight: 5),
                      const SizedBox(height: 5),
                      Text('${project.progress}% complete',
                          style: TextStyle(
                              fontSize: 11,
                              color: progressColor,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Due',
                        style:
                            TextStyle(fontSize: 10, color: AppColors.slate400)),
                    Text(project.dueDate,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
