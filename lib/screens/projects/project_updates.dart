part of 'projects_screen.dart';

class _ProjectUpdates extends StatelessWidget {
  final Project project;

  const _ProjectUpdates({required this.project});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrmAvatar(_initials(project.owner), size: AvatarSize.sm),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.owner,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                    const SizedBox(height: 6),
                    Text(
                        '${project.name} is ${project.progress}% complete and currently marked ${project.status}.',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slate600,
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
