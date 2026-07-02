import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_avatar.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/layout/app_shell.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  late Future<SettingsSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = CrmApi.instance.settings();
  }

  void _reload() => setState(() => _future = CrmApi.instance.settings());

  Future<void> _openSheet(SettingsSummary settings, [TeamMember? user]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamMemberSheet(settings: settings, user: user),
    );
    if (changed == true) _reload();
  }

  Future<void> _delete(TeamMember user) async {
    await CrmApi.instance.deleteUser(user.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final canManage = CrmApi.instance.canManageTeam();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(title: 'Team Members'),
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
              if (canManage)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openSheet(settings),
                      icon: const Icon(Icons.person_add_alt_rounded),
                      label: const Text('Add Team Member'),
                    ),
                  ),
                ),
              Expanded(
                child: settings.users.isEmpty
                    ? const ApiEmpty('No team members found.')
                    : RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: settings.users.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final user = settings.users[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Row(
                                children: [
                                  CrmAvatar(user.avatar, size: AvatarSize.md),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800)),
                                        Text(user.email,
                                            style: const TextStyle(
                                                color: AppColors.slate500)),
                                        Text(
                                            '${user.role} - ${user.department}'),
                                      ],
                                    ),
                                  ),
                                  CrmBadge(user.status),
                                  if (canManage)
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _openSheet(settings, user);
                                        }
                                        if (value == 'delete') _delete(user);
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                            value: 'edit', child: Text('Edit')),
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete')),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamMemberSheet extends StatefulWidget {
  final SettingsSummary settings;
  final TeamMember? user;

  const _TeamMemberSheet({required this.settings, this.user});

  @override
  State<_TeamMemberSheet> createState() => _TeamMemberSheetState();
}

class _TeamMemberSheetState extends State<_TeamMemberSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _title;
  late final TextEditingController _password;
  late String _role;
  late String _department;
  late String _status;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    final roles = _roles;
    final departments = _departments;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _title = TextEditingController(text: user?.title ?? '');
    _password = TextEditingController();
    _role = user?.role ?? roles.first;
    _department = user?.department ?? departments.first;
    _status = user?.status ?? 'Active';
  }

  List<String> get _roles => {
        'Admin',
        'Employee',
        ...widget.settings.roles.map((role) => role.name),
      }.where((item) => item.trim().isNotEmpty).toList();

  List<String> get _departments => {
        'Management',
        'General',
        ...widget.settings.departments.map((department) => department.name),
      }.where((item) => item.trim().isNotEmpty).toList();

  @override
  void dispose() {
    for (final ctrl in [_name, _email, _phone, _title, _password]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    if (widget.user == null && _password.text.trim().length < 8) {
      setState(
          () => _error = 'Initial password must be at least 8 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.saveUser({
        if (widget.user != null) 'id': widget.user!.id,
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'title': _title.text.trim(),
        'role': _role,
        'department': _department,
        'status': _status,
        if (_password.text.trim().isNotEmpty) 'password': _password.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      maxChildSize: 0.96,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.user == null ? 'Add Team Member' : 'Edit Team Member',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Job Title')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _roles.contains(_role) ? _role : _roles.first,
              decoration: const InputDecoration(labelText: 'Role'),
              items: _roles
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _role = value ?? _role),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _departments.contains(_department)
                  ? _department
                  : _departments.first,
              decoration: const InputDecoration(labelText: 'Department'),
              items: _departments
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _department = value ?? _department),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const ['Active', 'Inactive']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText:
                    widget.user == null ? 'Initial Password' : 'Reset Password',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Member'),
            ),
          ],
        ),
      ),
    );
  }
}
