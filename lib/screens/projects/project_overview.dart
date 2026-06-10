part of 'projects_screen.dart';

class _ProjectOverview extends StatelessWidget {
  final Project project;
  final VoidCallback? onAddPhase;
  final void Function(ProjectMilestone phase, String status)
      onPhaseStatusChanged;
  final ValueChanged<ProjectMilestone>? onUploadPhaseDocument;
  final void Function(ProjectMilestone phase, String documentId)?
      onDeletePhaseDocument;

  const _ProjectOverview({
    required this.project,
    required this.onAddPhase,
    required this.onPhaseStatusChanged,
    required this.onUploadPhaseDocument,
    required this.onDeletePhaseDocument,
  });

  @override
  Widget build(BuildContext context) {
    final phases = project.milestoneDetails;
    final canViewFinancials = CrmApi.instance.canViewFinancials();
    final canOpenCrmFlow = CrmApi.instance.canAccessRoute('/workflows');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _StatBox(
              'Due Date',
              project.dueDate,
              Icons.calendar_today_outlined,
            ),
            const SizedBox(width: 10),
            if (canViewFinancials)
              _StatBox(
                'Budget',
                project.budget ?? 'INR 0',
                Icons.attach_money_rounded,
              )
            else
              _StatBox(
                'Progress',
                '${project.progress}%',
                Icons.trending_up_rounded,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (canOpenCrmFlow) ...[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/workflows?projectId=${project.id}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.account_tree_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CRM Flow',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Owner',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                project.owner,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 8),
              if (project.ownerDesignation.isNotEmpty)
                Text(
                  project.ownerDesignation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
              if (project.ownerEmail.isNotEmpty)
                Text(
                  project.ownerEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
              if (project.ownerPhone.isNotEmpty)
                Text(
                  project.ownerPhone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Development Delivery Flow',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                  ),
                  if (onAddPhase != null)
                    TextButton.icon(
                      onPressed: onAddPhase,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (phases.isEmpty)
                const Text(
                  'No delivery phases added yet.',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400),
                )
              else
                ...phases.map((phase) {
                  final done = phase.status == 'Completed';
                  final documents = phase.documents;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                done
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 20,
                                color: done
                                    ? AppColors.success
                                    : AppColors.slate300,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phase.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: done
                                            ? AppColors.slate700
                                            : AppColors.slate500,
                                        fontWeight: done
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${phase.owner} / ${phase.dueDate}',
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
                              if (onUploadPhaseDocument != null)
                                IconButton(
                                  tooltip: 'Upload document',
                                  icon: const Icon(
                                    Icons.upload_file_rounded,
                                    size: 19,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () =>
                                      onUploadPhaseDocument?.call(phase),
                                ),
                              const SizedBox(width: 4),
                              if (onAddPhase != null)
                                DropdownButton<String>(
                                  value: [
                                    'Pending',
                                    'In Progress',
                                    'Completed',
                                  ].contains(phase.status)
                                      ? phase.status
                                      : 'Pending',
                                  underline: const SizedBox.shrink(),
                                  items: ['Pending', 'In Progress', 'Completed']
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (status) {
                                    if (status != null) {
                                      onPhaseStatusChanged(phase, status);
                                    }
                                  },
                                )
                              else
                                CrmBadge(phase.status),
                            ],
                          ),
                          if (documents.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...documents.map(
                              (document) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.surfaceBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.description_outlined,
                                      size: 15,
                                      color: AppColors.slate500,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        document.name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.slate600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (onDeletePhaseDocument != null)
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 17,
                                          color: AppColors.error,
                                        ),
                                        onPressed: () =>
                                            onDeletePhaseDocument?.call(
                                          phase,
                                          document.id,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
