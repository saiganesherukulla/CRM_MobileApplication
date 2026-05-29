part of 'workflows_screen.dart';

class _TimelineStage extends StatelessWidget {
  final String stage;
  final List<WorkflowItem> items;
  final VoidCallback onAdd;
  final ValueChanged<WorkflowItem> onEdit;

  const _TimelineStage({
    required this.stage,
    required this.items,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = _stageHeaderColor(stage);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Container(
                width: 2,
                height: items.isEmpty ? 84 : 128,
                color: AppColors.slate200,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _stageSurfaceColor(stage),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(stage,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate800),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add_rounded,
                            size: 18, color: AppColors.primary),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  if (items.isEmpty)
                    const Text('No item recorded for this stage yet.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.slate400))
                  else
                    ...items.map((item) => _WorkflowCard(
                          item: item,
                          onTap: () => onEdit(item),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
