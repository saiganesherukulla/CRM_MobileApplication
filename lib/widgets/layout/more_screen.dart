part of 'app_shell.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module('Emails', Icons.mail_rounded, '/emails', AppColors.primaryLight),

      _Module(
        'Tickets',
        Icons.confirmation_number_rounded,
        '/tickets',
        AppColors.warning,
      ),
      _Module(
        'Reports',
        Icons.bar_chart_rounded,
        '/reports',
        AppColors.success,
      ),
      _Module(
        'Settings',
        Icons.settings_rounded,
        '/settings',
        AppColors.slate500,
      ),
    ].where((module) => CrmApi.instance.canAccessRoute(module.route)).toList();
    final user = CrmApi.instance.currentUser;

    return Scaffold(
      appBar: const CrmAppBar(title: 'More'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      user.avatar,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.role,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Modules',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.slate400,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          if (modules.isEmpty)
            const Text(
              'No extra modules are enabled for this role.',
              style: TextStyle(color: AppColors.slate400),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: modules.map((m) => _ModuleTile(m)).toList(),
            ),
        ],
      ),
    );
  }
}
