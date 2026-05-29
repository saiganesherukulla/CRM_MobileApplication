part of 'projects_screen.dart';

class _ProjectTasks extends StatelessWidget {
  final List<CrmTask> tasks;

  const _ProjectTasks({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const ApiEmpty('No tasks for this project.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final task = tasks[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: priorityColor(task.priority),
                      shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(task.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              CrmBadge(task.status),
            ],
          ),
        );
      },
    );
  }
}
