part of 'client_detail_screen.dart';

class _Tasks extends StatelessWidget {
  final List<CrmTask> tasks;

  const _Tasks({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const ApiEmpty('No tasks for this client.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final task = tasks[index];
        return _CompactRow(
          leadingColor: priorityColor(task.priority),
          title: task.title,
          subtitle: '${task.assignee} - Due ${task.due}',
          badge: task.status,
        );
      },
    );
  }
}
