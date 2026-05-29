part of 'projects_screen.dart';

class _ProjectTeam extends StatelessWidget {
  final Project project;
  final List<CrmTask> tasks;
  final VoidCallback onAddMember;

  const _ProjectTeam({
    required this.project,
    required this.tasks,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    final members = project.team.isEmpty
        ? tasks
            .map((task) => task.assignee)
            .where((name) => name != 'Unassigned')
            .toSet()
            .toList()
        : project.team;
    if (members.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: onAddMember,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Add Team Member'),
          ),
          const SizedBox(height: 16),
          const ApiEmpty('No team members assigned yet.'),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: members.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        if (index == 0) {
          return Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onAddMember,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Add Member'),
            ),
          );
        }
        final memberIndex = index - 1;
        final name = members[memberIndex];
        final assigned = tasks.where((task) => task.assignee == name).length;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: Row(
            children: [
              CrmAvatar(_initials(name), size: AvatarSize.md),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const Text('Project team',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.slate400)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(999)),
                child: Text('$assigned tasks',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      },
    );
  }
}
