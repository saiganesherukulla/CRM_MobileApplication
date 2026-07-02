import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/crm_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/api_state.dart';
import '../../widgets/common/crm_avatar.dart';
import '../../widgets/common/crm_badge.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/layout/app_shell.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  late Future<_SuperAdminData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SuperAdminData> _load() async {
    final settings = await CrmApi.instance.settings();
    final clients =
        await CrmApi.instance.clients().catchError((_) => <Client>[]);
    final projects =
        await CrmApi.instance.projects().catchError((_) => <Project>[]);
    return _SuperAdminData(settings, clients, projects);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _grant(_SuperAdminData data) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GrantAccessSheet(data: data),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CrmAppBar(title: 'Super Admin'),
      body: FutureBuilder<_SuperAdminData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApiLoading();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ApiErrorView(error: snapshot.error, onRetry: _reload);
          }
          final data = snapshot.data!;
          final granted = data.settings.users
              .where((user) => !{'SUPER_ADMIN', 'CLIENT'}
                  .contains(user.role.toUpperCase().replaceAll(' ', '_')))
              .toList();
          final admins = granted
              .where((user) =>
                  user.role.toUpperCase().replaceAll(' ', '_') == 'ADMIN')
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ElevatedButton.icon(
                onPressed: () => _grant(data),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Grant Access'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                      child: StatCard(
                          title: 'People Given Access',
                          value: granted.length.toString(),
                          icon: Icons.people_alt_rounded,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.primarySurface)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          title: 'Admins',
                          value: admins.length.toString(),
                          icon: Icons.shield_rounded,
                          iconColor: AppColors.success,
                          iconBg: AppColors.successLight)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: StatCard(
                          title: 'Companies',
                          value: data.clients.length.toString(),
                          icon: Icons.business_rounded,
                          iconColor: AppColors.info,
                          iconBg: AppColors.infoLight)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          title: 'Projects',
                          value: data.projects.length.toString(),
                          icon: Icons.folder_rounded,
                          iconColor: AppColors.warning,
                          iconBg: AppColors.warningLight)),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Granted Access',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (granted.isEmpty)
                const ApiEmpty('No organization access has been granted yet.')
              else
                ...granted.map((user) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
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
                                        fontWeight: FontWeight.w800)),
                                Text(user.email,
                                    style: const TextStyle(
                                        color: AppColors.slate500)),
                                Text(user.department),
                              ],
                            ),
                          ),
                          CrmBadge(user.role),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _GrantAccessSheet extends StatefulWidget {
  final _SuperAdminData data;

  const _GrantAccessSheet({required this.data});

  @override
  State<_GrantAccessSheet> createState() => _GrantAccessSheetState();
}

class _GrantAccessSheetState extends State<_GrantAccessSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _title = TextEditingController();
  final _password = TextEditingController();
  late String _department;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _department = _departments.first;
  }

  List<String> get _departments => {
        'Management',
        'General',
        ...widget.data.settings.departments
            .map((department) => department.name),
      }.where((item) => item.trim().isNotEmpty).toList();

  @override
  void dispose() {
    for (final ctrl in [_name, _email, _phone, _title, _password]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.trim().length < 8) {
      setState(
          () => _error = 'Name, email, and 8 character password are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.saveUser({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'title': _title.text.trim(),
        'role': 'Admin',
        'department': _department,
        'status': 'Active',
        'password': _password.text.trim(),
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
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Grant Admin Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
              value: _department,
              decoration: const InputDecoration(labelText: 'Department'),
              items: _departments
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _department = value ?? _department),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _password,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Initial Password')),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Grant Access'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuperAdminData {
  final SettingsSummary settings;
  final List<Client> clients;
  final List<Project> projects;

  const _SuperAdminData(this.settings, this.clients, this.projects);
}
