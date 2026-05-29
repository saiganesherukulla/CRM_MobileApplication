part of 'settings_screen.dart';

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeSection = 'Profile';
  late Future<SettingsSummary> _future;

  static const _sections = [
    ('Profile', Icons.person_outline_rounded),
    ('Users', Icons.people_outline_rounded),
    ('Roles', Icons.shield_outlined),
    ('Departments', Icons.business_outlined),
    ('Email Config', Icons.mail_outline_rounded),
    ('Notifications', Icons.notifications_outlined),
    ('Security', Icons.lock_outline_rounded),
    ('System', Icons.dns_outlined),
    ('Audit Logs', Icons.history_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.settings();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.settings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(title: 'Settings', actions: [
        IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _reload)
      ]),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sections.map((section) {
                  final active = _activeSection == section.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeSection = section.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color:
                                active ? AppColors.primary : AppColors.slate100,
                            borderRadius: BorderRadius.circular(999)),
                        child: Row(
                          children: [
                            Icon(section.$2,
                                size: 14,
                                color:
                                    active ? Colors.white : AppColors.slate600),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(section.$1,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? Colors.white
                                          : AppColors.slate600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<SettingsSummary>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ApiLoading();
                }
                if (snapshot.hasError) {
                  return ApiErrorView(error: snapshot.error, onRetry: _reload);
                }
                final data = snapshot.data ??
                    const SettingsSummary(
                        users: [],
                        roles: [],
                        departments: [],
                        emailAccounts: [],
                        emailProviders: []);
                return _buildSection(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(SettingsSummary data) {
    return switch (_activeSection) {
      'Profile' => _ProfileSection(onChanged: _reload),
      'Users' => _UsersSection(
          users: data.users,
          roles: data.roles,
          departments: data.departments,
          onChanged: _reload,
        ),
      'Roles' => _RolesSection(roles: data.roles, onChanged: _reload),
      'Departments' => _DepartmentsSection(
          departments: data.departments,
          onChanged: _reload,
        ),
      'Email Config' => _EmailConfigSection(
          accounts: data.emailAccounts,
          providers: data.emailProviders,
          onChanged: _reload,
        ),
      'Notifications' => const _NotificationsSection(),
      'Security' => const _SecuritySection(),
      'System' => const _SystemSection(),
      'Audit Logs' => const _AuditLogsSection(),
      _ => const SizedBox.shrink(),
    };
  }
}
