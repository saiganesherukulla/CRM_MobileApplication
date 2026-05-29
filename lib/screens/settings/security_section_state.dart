part of 'settings_screen.dart';

class _SecuritySectionState extends State<_SecuritySection> {
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _mfa = false;
  bool _sessionTimeout = true;
  bool _loginAlerts = true;
  bool _savingPassword = false;
  String? _passwordError;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordCtrl.text;
    final newPassword = _newPasswordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;
    if (newPassword.length < 8) {
      setState(
          () => _passwordError = 'New password must be at least 8 characters.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(
          () => _passwordError = 'New password and confirmation do not match.');
      return;
    }
    setState(() {
      _savingPassword = true;
      _passwordError = null;
    });
    try {
      await CrmApi.instance.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password updated.')));
      }
    } catch (error) {
      if (mounted) setState(() => _passwordError = error.toString());
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _saveSecurityToggle(String key, bool value) async {
    setState(() {
      if (key == 'mfa') _mfa = value;
      if (key == 'sessionTimeout') _sessionTimeout = value;
      if (key == 'loginAlerts') _loginAlerts = value;
    });
    try {
      await CrmApi.instance.savePreference('security.$key', {'enabled': value});
    } catch (error) {
      if (mounted) _showInfo(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Security Settings',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 14),
        _ToggleTile(
            title: 'Two-Factor Authentication',
            subtitle: 'Require MFA on login',
            value: _mfa,
            onChanged: (value) => _saveSecurityToggle('mfa', value)),
        _ToggleTile(
            title: 'Session Timeout',
            subtitle: 'Auto logout after 30 min inactivity',
            value: _sessionTimeout,
            onChanged: (value) => _saveSecurityToggle('sessionTimeout', value)),
        _ToggleTile(
            title: 'Login Alerts',
            subtitle: 'Email me when a new device signs in',
            value: _loginAlerts,
            onChanged: (value) => _saveSecurityToggle('loginAlerts', value)),
        const SizedBox(height: 20),
        const Text('Change Password',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 14),
        _FormCard(children: [
          TextField(
              controller: _currentPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password')),
          const SizedBox(height: 14),
          TextField(
              controller: _newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password')),
          const SizedBox(height: 14),
          TextField(
              controller: _confirmPasswordCtrl,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirm New Password')),
          if (_passwordError != null) ...[
            const SizedBox(height: 12),
            Text(_passwordError!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _savingPassword ? null : _updatePassword,
            child: _savingPassword
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Update Password'),
          ),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.2))),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign Out This Device',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error)),
                    Text('Clear the stored mobile session',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.slate400)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await CrmApi.instance.signOut();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Sign Out',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
