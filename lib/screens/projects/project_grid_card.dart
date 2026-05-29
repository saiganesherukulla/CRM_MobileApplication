part of 'projects_screen.dart';

class _ProjectGridCard extends StatelessWidget {
  final Project project;
  final Color progressColor;

  const _ProjectGridCard({required this.project, required this.progressColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(projectId: project.id))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.folder_rounded,
                        color: progressColor, size: 18)),
                const Spacer(),
                CrmBadge(project.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(project.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(project.client,
                style: const TextStyle(fontSize: 11, color: AppColors.slate400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            LinearProgressIndicator(
                value: project.progress / 100,
                backgroundColor: AppColors.slate100,
                valueColor: AlwaysStoppedAnimation(progressColor),
                minHeight: 4),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${project.progress}%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: progressColor)),
                const Spacer(),
                Text(project.dueDate,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.slate400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
