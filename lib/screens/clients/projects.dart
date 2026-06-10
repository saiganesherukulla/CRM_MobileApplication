part of 'client_detail_screen.dart';

class _Projects extends StatelessWidget {
  final List<Project> projects;

  const _Projects({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) return const ApiEmpty('No projects for this client.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final project = projects[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/projects/${project.id}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CrmBadge(project.status),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: project.progress / 100,
                  backgroundColor: AppColors.slate100,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 5,
                ),
                const SizedBox(height: 6),
                Text(
                  '${project.progress}% complete - Due ${project.dueDate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
