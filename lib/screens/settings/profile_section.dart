part of 'settings_screen.dart';

class _ProfileSection extends StatefulWidget {
  final VoidCallback onChanged;

  const _ProfileSection({required this.onChanged});

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _departmentCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = CrmApi.instance.currentUser;
    final parts = (user?.name ?? '').split(' ');
    _firstNameCtrl = TextEditingController(text: parts.isNotEmpty ? parts.first : '');
    _lastNameCtrl = TextEditingController(
        text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _roleCtrl = TextEditingController(text: user?.role ?? '');
    _phoneCtrl = TextEditingController();
    _titleCtrl = TextEditingController(text: user?.role ?? '');
    _departmentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    _titleCtrl.dispose();
    _departmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = CrmApi.instance.currentUser;
    if (user == null || _emailCtrl.text.trim().isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.saveUser({
        'id': user.id,
        'name': [_firstNameCtrl.text.trim(), _lastNameCtrl.text.trim()]
            .where((part) => part.isNotEmpty)
            .join(' '),
        'email': _emailCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'department': _departmentCtrl.text.trim(),
        'status': 'Active',
      });
      widget.onChanged();
      if (mounted) _showInfo(context, 'Profile saved.');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = CrmApi.instance.currentUser;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CrmAvatar(user?.avatar ?? 'NA', size: AvatarSize.lg),
        ),
        const SizedBox(height: 20),
        _FormCard(children: [
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _firstNameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'First Name'))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name'))),
          ]),
          const SizedBox(height: 14),
          TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 14),
          TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(labelText: 'Role')),
          const SizedBox(height: 14),
          TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 14),
          TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Job Title')),
          const SizedBox(height: 14),
          TextField(
              controller: _departmentCtrl,
              decoration: const InputDecoration(labelText: 'Department')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _saveProfile,
            child: Text(_saving ? 'Saving...' : 'Save Profile'),
          ),
        ]),
      ],
    );
  }
}
