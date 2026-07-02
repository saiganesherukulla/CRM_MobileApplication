part of 'workflows_screen.dart';

class _FlowIntro extends StatelessWidget {
  const _FlowIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project flows by client',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
                SizedBox(height: 2),
                Text('Open a project to view and edit its CTRL F journey.',
                    style: TextStyle(fontSize: 12, color: AppColors.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
