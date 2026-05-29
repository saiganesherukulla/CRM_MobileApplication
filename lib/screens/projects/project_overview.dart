part of 'projects_screen.dart';

class _ProjectOverview extends StatelessWidget {
  final Project project;
  final VoidCallback onAddPhase;
  final void Function(ProjectMilestone phase, String status) onPhaseStatusChanged;

  const _ProjectOverview({
    required this.project,
    required this.onAddPhase,
    required this.onPhaseStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final phases = project.milestoneDetails;
    final canViewFinancials = CrmApi.instance.canViewFinancials();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          _StatBox('Due Date', project.dueDate, Icons.calendar_today_outlined),
          const SizedBox(width: 10),
          if (canViewFinancials)
            _StatBox(
                'Budget', project.budget ?? 'INR 0', Icons.attach_money_rounded)
          else
            _StatBox(
                'Progress', '${project.progress}%', Icons.trending_up_rounded)
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Development Delivery Flow',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                  ),
                  TextButton.icon(
                    onPressed: onAddPhase,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (phases.isEmpty)
                const Text('No delivery phases added yet.',
                    style: TextStyle(fontSize: 12, color: AppColors.slate400))
              else
                ...phases.map((phase) {
                final done = phase.status == 'Completed';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: done ? AppColors.success : AppColors.slate300),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(phase.name,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: done
                                        ? AppColors.slate700
                                        : AppColors.slate500,
                                    fontWeight: done
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('${phase.owner} / ${phase.dueDate}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.slate400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: ['Pending', 'In Progress', 'Completed']
                                .contains(phase.status)
                            ? phase.status
                            : 'Pending',
                        underline: const SizedBox.shrink(),
                        items: ['Pending', 'In Progress', 'Completed']
                            .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status,
                                    style: const TextStyle(fontSize: 11))))
                            .toList(),
                        onChanged: (status) {
                          if (status != null) onPhaseStatusChanged(phase, status);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
