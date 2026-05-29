part of 'settings_screen.dart';

class _UsersSection extends StatelessWidget {
  final List<TeamMember> users;
  final List<RoleInfo> roles;
  final List<DepartmentInfo> departments;
  final VoidCallback onChanged;

  const _UsersSection({
    required this.users,
    required this.roles,
    required this.departments,
    required this.onChanged,
  });

  static const _fallbackRoles = [
    'Founder',
    'Super Admin',
    'Operations Admin',
    'Manager / Team Lead',
    'Project Manager',
    'Developer',
    'Designer',
    'QA / Tester',
    'Support Executive',
    'Finance',
    'Viewer',
  ];

  static const _fallbackDepartments = [
    'Management',
    'Development',
    'Design',
    'Testing / QA',
    'Support',
    'Finance',
    'Client Relations',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final canManage = CrmApi.instance.canManageTeam();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Team Members',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
            ),
            if (canManage)
              ElevatedButton.icon(
                onPressed: () => _openUserSheet(context),
                icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Only Founder, Super Admin, Operations Admin, and Manager / Team Lead roles can add team members.',
          style: TextStyle(fontSize: 11, color: AppColors.slate400),
        ),
        const SizedBox(height: 14),
        if (users.isEmpty)
          const ApiEmpty('No users found.')
        else
          ...users.map((user) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder)),
                child: Row(
                  children: [
                    CrmAvatar(user.avatar, size: AvatarSize.md),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(user.email,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.slate400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (user.title.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(user.title,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.slate500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Chip(user.role, AppColors.primary),
                        const SizedBox(height: 4),
                        _Chip(
                            user.status,
                            user.status == 'Active'
                                ? AppColors.success
                                : AppColors.slate500),
                      ],
                    ),
                    if (canManage) ...[
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: AppColors.slate400),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openUserSheet(context, user: user);
                          } else if (value == 'inactive') {
                            _setUserStatus(context, user, 'Inactive');
                          } else if (value == 'active') {
                            _setUserStatus(context, user, 'Active');
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('Edit member')),
                          PopupMenuItem(
                              value: user.status == 'Active'
                                  ? 'inactive'
                                  : 'active',
                              child: Text(user.status == 'Active'
                                  ? 'Deactivate'
                                  : 'Activate')),
                        ],
                      ),
                    ],
                  ],
                ),
              )),
      ],
    );
  }

  List<String> _roleOptions() {
    return {
      ...roles.map((role) => role.name).where((name) => name.trim().isNotEmpty),
      ..._fallbackRoles,
    }.toList();
  }

  List<String> _departmentOptions() {
    return {
      ...departments
          .map((department) => department.name)
          .where((name) => name.trim().isNotEmpty),
      ..._fallbackDepartments,
    }.toList();
  }

  void _openUserSheet(BuildContext context, {TeamMember? user}) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final titleController = TextEditingController(text: user?.title ?? '');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final roleOptions = _roleOptions();
    final departmentOptions = _departmentOptions();
    String role = user?.role ?? roleOptions.first;
    String department = user?.department ?? departmentOptions.first;
    String status = user?.status ?? 'Active';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user == null ? 'Add Team Member' : 'Edit Team Member',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate800)),
                    const SizedBox(height: 16),
                    _field(nameController, 'Full name',
                        icon: Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    _field(emailController, 'Email address',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _field(phoneController, 'Phone number',
                        icon: Icons.phone_outlined,
                        requiredField: false,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _field(titleController, 'Job title',
                        icon: Icons.badge_outlined, requiredField: false),
                    const SizedBox(height: 12),
                    _dropdown(
                      value: role,
                      label: 'Role',
                      values: roleOptions,
                      onChanged: (value) => setSheetState(() => role = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      value: department,
                      label: 'Department',
                      values: departmentOptions,
                      onChanged: (value) =>
                          setSheetState(() => department = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      value: status,
                      label: 'Status',
                      values: const ['Active', 'Inactive'],
                      onChanged: (value) => setSheetState(() => status = value),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      passwordController,
                      user == null ? 'Initial password' : 'Reset password',
                      icon: Icons.lock_outline_rounded,
                      requiredField: user == null,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          await _saveUser(
                            sheetContext,
                            id: user?.id,
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            title: titleController.text,
                            role: role,
                            department: department,
                            status: status,
                            password: passwordController.text,
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label:
                            Text(user == null ? 'Add Member' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      titleController.dispose();
      passwordController.dispose();
    });
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    bool requiredField = true,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (requiredField && text.isEmpty) return '$label is required';
        if (obscureText && text.isNotEmpty && text.length < 8) {
          return '$label must be at least 8 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required String label,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: values.contains(value) ? value : values.first,
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _saveUser(
    BuildContext context, {
    String? id,
    required String name,
    required String email,
    required String phone,
    required String title,
    required String role,
    required String department,
    required String status,
    required String password,
    bool closeSheet = true,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await CrmApi.instance.saveUser({
        if (id != null) 'id': id,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'title': title.trim(),
        'role': role,
        'department': department,
        'status': status,
        if (password.trim().isNotEmpty) 'password': password.trim(),
      });
      if (closeSheet && navigator.canPop()) navigator.pop();
      onChanged();
      messenger
          .showSnackBar(const SnackBar(content: Text('Team member saved')));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _setUserStatus(
      BuildContext context, TeamMember user, String status) async {
    await _saveUser(
      context,
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      title: user.title,
      role: user.role,
      department: user.department,
      status: status,
      password: '',
      closeSheet: false,
    );
  }
}
