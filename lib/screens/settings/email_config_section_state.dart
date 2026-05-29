part of 'settings_screen.dart';

class _EmailConfigSectionState extends State<_EmailConfigSection> {
  bool _autoAssign = true;
  bool _tracking = true;
  bool _signature = false;
  bool _working = false;

  Future<void> _sync(EmailAccountInfo account) async {
    setState(() => _working = true);
    try {
      final result = await CrmApi.instance.syncEmailAccount(account.id);
      if (!mounted) return;
      _showInfo(context, result.message);
      widget.onChanged();
    } catch (error) {
      if (mounted) _showInfo(context, error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _disconnect(EmailAccountInfo account) async {
    setState(() => _working = true);
    try {
      await CrmApi.instance.disconnectEmailAccount(account.id);
      if (!mounted) return;
      _showInfo(context, 'Email account disconnected');
      widget.onChanged();
    } catch (error) {
      if (mounted) _showInfo(context, error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    setState(() {
      if (key == 'autoAssign') _autoAssign = value;
      if (key == 'tracking') _tracking = value;
      if (key == 'signature') _signature = value;
    });
    try {
      await CrmApi.instance.savePreference('email.$key', {'enabled': value});
    } catch (error) {
      if (mounted) _showInfo(context, error.toString());
    }
  }

  void _openProviderSheet({EmailProviderInfo? provider}) {
    const templates = {
      'zoho': (
        'Zoho Mail',
        'accounts.zoho.in',
        'ZohoMail.accounts.READ, ZohoMail.messages.READ, ZohoMail.messages.CREATE'
      ),
      'google': (
        'Google Gmail',
        '',
        'openid, email, profile, https://www.googleapis.com/auth/gmail.send, https://www.googleapis.com/auth/gmail.readonly'
      ),
      'microsoft': (
        'Microsoft 365',
        'common',
        'openid, profile, email, offline_access, User.Read, Mail.Read, Mail.Send'
      ),
    };
    final providerCtrl = TextEditingController(text: provider?.provider ?? 'zoho');
    final displayCtrl = TextEditingController(
        text: provider?.displayName ?? templates['zoho']!.$1);
    final clientIdCtrl = TextEditingController(text: provider?.clientId ?? '');
    final secretCtrl = TextEditingController();
    final redirectCtrl = TextEditingController(
        text: provider?.redirectUri ??
            'http://localhost:8080/api/email-accounts/oauth/zoho/callback');
    final dataCenterCtrl = TextEditingController(
        text: provider?.dataCenter ?? templates['zoho']!.$2);
    final scopesCtrl = TextEditingController(
        text: provider?.scopes.join(', ') ?? templates['zoho']!.$3);
    var enabled = provider?.enabled ?? true;
    var saving = false;
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (context, setSheetState) {
          void providerChanged(String value) {
            final template = templates[value] ?? templates['zoho']!;
            providerCtrl.text = value;
            displayCtrl.text = template.$1;
            dataCenterCtrl.text = template.$2;
            scopesCtrl.text = template.$3;
            redirectCtrl.text =
                'http://localhost:8080/api/email-accounts/oauth/$value/callback';
            setSheetState(() {});
          }

          Future<void> save() async {
            if (clientIdCtrl.text.trim().isEmpty ||
                (provider == null && secretCtrl.text.trim().isEmpty)) {
              setSheetState(() =>
                  error = 'Client ID and client secret are required.');
              return;
            }
            setSheetState(() {
              saving = true;
              error = null;
            });
            try {
              await CrmApi.instance.saveEmailProvider({
                if (provider != null) 'id': provider.id,
                'provider': providerCtrl.text.trim(),
                'displayName': displayCtrl.text.trim(),
                'clientId': clientIdCtrl.text.trim(),
                if (secretCtrl.text.trim().isNotEmpty)
                  'clientSecret': secretCtrl.text.trim(),
                'redirectUri': redirectCtrl.text.trim(),
                'dataCenter': dataCenterCtrl.text.trim(),
                'scopes': scopesCtrl.text
                    .split(',')
                    .map((scope) => scope.trim())
                    .where((scope) => scope.isNotEmpty)
                    .toList(),
                'enabled': enabled,
              });
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              widget.onChanged();
              if (context.mounted) _showInfo(context, 'Email provider saved.');
            } catch (err) {
              setSheetState(() => error = err.toString());
            } finally {
              if (context.mounted) {
                setSheetState(() => saving = false);
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider == null ? 'Add Email Provider' : 'Edit Email Provider',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate800)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: ['zoho', 'google', 'microsoft']
                            .contains(providerCtrl.text)
                        ? providerCtrl.text
                        : 'zoho',
                    decoration: const InputDecoration(labelText: 'Provider'),
                    items: const [
                      DropdownMenuItem(value: 'zoho', child: Text('Zoho Mail')),
                      DropdownMenuItem(value: 'google', child: Text('Google Gmail')),
                      DropdownMenuItem(value: 'microsoft', child: Text('Microsoft 365')),
                    ],
                    onChanged: (value) {
                      if (value != null) providerChanged(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: displayCtrl, decoration: const InputDecoration(labelText: 'Display Name')),
                  const SizedBox(height: 12),
                  TextField(controller: clientIdCtrl, decoration: const InputDecoration(labelText: 'Client ID')),
                  const SizedBox(height: 12),
                  TextField(controller: secretCtrl, obscureText: true, decoration: InputDecoration(labelText: provider == null ? 'Client Secret' : 'Client Secret (leave blank to keep)')),
                  const SizedBox(height: 12),
                  TextField(controller: redirectCtrl, decoration: const InputDecoration(labelText: 'Redirect URI')),
                  const SizedBox(height: 12),
                  TextField(controller: dataCenterCtrl, decoration: const InputDecoration(labelText: 'Data Center / Tenant')),
                  const SizedBox(height: 12),
                  TextField(controller: scopesCtrl, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Scopes')),
                  SwitchListTile(
                    value: enabled,
                    onChanged: (value) => setSheetState(() => enabled = value),
                    title: const Text('Enable provider'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : save,
                      child: Text(saving ? 'Saving...' : 'Save Provider'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).whenComplete(() {
      providerCtrl.dispose();
      displayCtrl.dispose();
      clientIdCtrl.dispose();
      secretCtrl.dispose();
      redirectCtrl.dispose();
      dataCenterCtrl.dispose();
      scopesCtrl.dispose();
    });
  }

  void _openEmailAccountSheet() {
    final user = CrmApi.instance.currentUser;
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    var provider = widget.providers.isNotEmpty
        ? widget.providers.first.provider
        : 'zoho';
    var saving = false;
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (context, setSheetState) {
          Future<void> saveManual() async {
            if (emailCtrl.text.trim().isEmpty) {
              setSheetState(() => error = 'Email is required.');
              return;
            }
            setSheetState(() {
              saving = true;
              error = null;
            });
            try {
              await CrmApi.instance.saveEmailAccount({
                'userId': user?.id,
                'email': emailCtrl.text.trim(),
                'provider': provider,
                'status': 'Disconnected',
              });
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              widget.onChanged();
              if (context.mounted) _showInfo(context, 'Email account saved.');
            } catch (err) {
              setSheetState(() => error = err.toString());
            } finally {
              if (context.mounted) {
                setSheetState(() => saving = false);
              }
            }
          }

          Future<void> startOAuth() async {
            if (user == null || emailCtrl.text.trim().isEmpty) {
              setSheetState(() => error = 'Signed-in user and email are required.');
              return;
            }
            setSheetState(() {
              saving = true;
              error = null;
            });
            try {
              final result = await CrmApi.instance.startEmailOAuth(
                provider,
                userId: user.id,
                email: emailCtrl.text.trim(),
              );
              if (context.mounted) {
                _showInfo(context,
                    'OAuth URL generated: ${result['authorizationUrl'] ?? 'not returned'}');
              }
            } catch (err) {
              setSheetState(() => error = err.toString());
            } finally {
              if (context.mounted) {
                setSheetState(() => saving = false);
              }
            }
          }

          final providerOptions = {
            ...widget.providers.map((item) => item.provider),
            'zoho',
            'google',
            'microsoft',
          }.toList();
          return Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 18,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connect Email Account',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate800)),
                  const SizedBox(height: 16),
                  TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Mailbox Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: providerOptions.contains(provider)
                        ? provider
                        : providerOptions.first,
                    decoration: const InputDecoration(labelText: 'Provider'),
                    items: providerOptions
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => setSheetState(() => provider = value ?? provider),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: saving ? null : saveManual,
                          child: const Text('Save Manual'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saving ? null : startOAuth,
                          child: Text(saving ? 'Working...' : 'Start OAuth'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    ).whenComplete(() => emailCtrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Email Providers',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _openProviderSheet(),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Provider'),
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
          ),
        ),
        const SizedBox(height: 14),
        if (widget.providers.isEmpty)
          const Text('No email providers configured yet.',
              style: TextStyle(color: AppColors.slate400))
        else
          ...widget.providers.map((provider) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder)),
                child: Row(
                  children: [
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.key_rounded,
                            color: AppColors.slate500, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.displayName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(provider.dataCenter.isEmpty
                              ? provider.provider
                              : '${provider.provider} / ${provider.dataCenter}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.slate400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    _Chip(provider.enabled ? 'Enabled' : 'Disabled',
                        provider.enabled ? AppColors.success : AppColors.slate400),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.slate400),
                      onPressed: () => _openProviderSheet(provider: provider),
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 20),
        const Text('Connected Accounts',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 14),
        if (widget.accounts.isEmpty)
          const Text('No email accounts connected.',
              style: TextStyle(color: AppColors.slate400))
        else
          ...widget.accounts.map((account) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EmailAccountCard(account,
                    onSync: _working ? () {} : () => _sync(account),
                    onDisconnect: _working ? () {} : () => _disconnect(account)),
              )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openEmailAccountSheet,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Connect Email Account'),
        ),
        const SizedBox(height: 20),
        const Text('Email Settings',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        const SizedBox(height: 14),
        _ToggleTile(
            title: 'Auto-assign Incoming Emails',
            subtitle: 'Automatically assign emails based on client ownership',
            value: _autoAssign,
            onChanged: (value) => _savePreference('autoAssign', value)),
        _ToggleTile(
            title: 'Email Open Tracking',
            subtitle: 'Track when recipients open your emails',
            value: _tracking,
            onChanged: (value) => _savePreference('tracking', value)),
        _ToggleTile(
            title: 'Email Signature',
            subtitle: 'Automatically append your signature to emails',
            value: _signature,
            onChanged: (value) => _savePreference('signature', value)),
      ],
    );
  }
}
