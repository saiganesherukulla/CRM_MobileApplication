import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/layout/app_shell.dart';

class CustomScreen extends StatefulWidget {
  const CustomScreen({super.key});

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<SettingsSummary> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _future = CrmApi.instance.settings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _future = CrmApi.instance.settings());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(title: 'Custom'),
      body: FutureBuilder<SettingsSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final settings = snapshot.data!;
          return Column(
            children: [
              Material(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Departments'),
                    Tab(text: 'Roles'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _DepartmentsTab(
                        departments: settings.departments, onChanged: _reload),
                    _RolesTab(roles: settings.roles, onChanged: _reload),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DepartmentsTab extends StatelessWidget {
  final List<DepartmentInfo> departments;
  final VoidCallback onChanged;

  const _DepartmentsTab({required this.departments, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _openDepartmentSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Department'),
        ),
        const SizedBox(height: 14),
        if (departments.isEmpty)
          const ApiEmpty('No departments configured.')
        else
          ...departments.map((department) => _customCard(
                icon: Icons.business_outlined,
                title: department.name,
                subtitle:
                    '${department.members} members - Head: ${department.head}',
                actions: [
                  IconButton(
                    onPressed: () => _openDepartmentSheet(context, department),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      await CrmApi.instance.deleteDepartment(department.id);
                      onChanged();
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                  ),
                ],
              )),
      ],
    );
  }

  void _openDepartmentSheet(BuildContext context,
      [DepartmentInfo? department]) {
    final name = TextEditingController(text: department?.name ?? '');
    final head = TextEditingController(text: department?.head ?? '');
    final members =
        TextEditingController(text: (department?.members ?? 0).toString());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(department == null ? 'Add Department' : 'Edit Department',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(
                controller: head,
                decoration: const InputDecoration(labelText: 'Head')),
            const SizedBox(height: 12),
            TextField(
                controller: members,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Members')),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                await CrmApi.instance.saveDepartment({
                  if (department != null) 'id': department.id,
                  'name': name.text.trim(),
                  'head': head.text.trim(),
                  'members': int.tryParse(members.text.trim()) ?? 0,
                });
                if (context.mounted) Navigator.pop(context);
                onChanged();
              },
              child: const Text('Save Department'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      name.dispose();
      head.dispose();
      members.dispose();
    });
  }
}

class _RolesTab extends StatelessWidget {
  final List<RoleInfo> roles;
  final VoidCallback onChanged;

  const _RolesTab({required this.roles, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _openRoleSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Role'),
        ),
        const SizedBox(height: 14),
        if (roles.isEmpty)
          const ApiEmpty('No custom roles configured.')
        else
          ...roles.map((role) => _customCard(
                icon: Icons.verified_user_outlined,
                title: role.name,
                subtitle: role.description,
                trailing: CrmBadge('${role.permissions.length} permissions'),
                actions: [
                  IconButton(
                    onPressed: () => _openRoleSheet(context, role),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () async {
                      await CrmApi.instance.deleteRole(role.id);
                      onChanged();
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                  ),
                ],
              )),
      ],
    );
  }

  void _openRoleSheet(BuildContext context, [RoleInfo? role]) {
    final name = TextEditingController(text: role?.name ?? '');
    final description = TextEditingController(text: role?.description ?? '');
    final permissions =
        TextEditingController(text: role?.permissions.join(', ') ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(role == null ? 'Add Role' : 'Edit Role',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            TextField(
              controller: permissions,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Permissions'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                await CrmApi.instance.saveRole({
                  if (role != null) 'id': role.id,
                  'name': name.text.trim(),
                  'description': description.text.trim(),
                  'permissions': permissions.text
                      .split(',')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(),
                });
                if (context.mounted) Navigator.pop(context);
                onChanged();
              },
              child: const Text('Save Role'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      name.dispose();
      description.dispose();
      permissions.dispose();
    });
  }
}

Widget _customCard({
  required IconData icon,
  required String title,
  required String subtitle,
  Widget? trailing,
  required List<Widget> actions,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.surfaceBorder),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (trailing != null) ...[const SizedBox(height: 6), trailing],
            ],
          ),
        ),
        ...actions,
      ],
    ),
  );
}
