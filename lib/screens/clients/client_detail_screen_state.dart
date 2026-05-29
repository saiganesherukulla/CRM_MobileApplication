part of 'client_detail_screen.dart';

class _ClientDetailScreenState extends State<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Overview',
    'Contacts',
    'Tasks',
    'Projects',
    'Emails',
    'Tickets'
  ];

  late TabController _tabCtrl;
  late Future<ClientSummary> _future;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _future = CrmApi.instance.clientSummary(widget.clientId);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = CrmApi.instance.clientSummary(widget.clientId);
    });
  }

  Future<void> _showAddContactSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddContactSheet(clientId: widget.clientId),
    );
    if (created == true) _reload();
  }

  Future<void> _showEditClientSheet(ClientSummary summary) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditClientSheet(summary: summary),
    );
    if (changed == true) _reload();
  }

  Future<void> _deleteClient(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete client?'),
        content: Text('This will remove ${client.name} from the CRM.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await CrmApi.instance.deleteClient(client.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClientSummary>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: AppColors.background, body: ApiLoading());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
              backgroundColor: AppColors.background,
              body: ApiErrorView(error: snapshot.error, onRetry: _reload));
        }

        final summary = snapshot.data!;
        final client = summary.client;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 230,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditClientSheet(summary)),
                  IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _deleteClient(client)),
                  IconButton(
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      onPressed: _showAddContactSheet),
                  IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _reload),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 72),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CrmAvatar(client.avatar, size: AvatarSize.lg),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(client.name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.slate800),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('${client.industry} - ${client.country}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.slate400),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: CrmBadge(client.status, dot: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: TabBar(
                    controller: _tabCtrl,
                    isScrollable: true,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.slate500,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                ),
              ),
            ],
            body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _reload(),
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _Overview(summary: summary),
                  _Contacts(contacts: summary.contacts),
                  _Tasks(tasks: summary.tasks),
                  _Projects(projects: summary.projects),
                  _Emails(emails: summary.emails),
                  _Tickets(tickets: summary.tickets),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditClientSheet extends StatefulWidget {
  final ClientSummary summary;

  const _EditClientSheet({required this.summary});

  @override
  State<_EditClientSheet> createState() => _EditClientSheetState();
}

class _EditClientSheetState extends State<_EditClientSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _industryCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _contactNameCtrl;
  late final TextEditingController _contactEmailCtrl;
  late final TextEditingController _contactPhoneCtrl;
  late final TextEditingController _contactDesignationCtrl;
  late String _status;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final client = widget.summary.client;
    Contact? primary;
    for (final contact in widget.summary.contacts) {
      if (contact.primary) {
        primary = contact;
        break;
      }
    }
    primary ??=
        widget.summary.contacts.isEmpty ? null : widget.summary.contacts.first;
    _nameCtrl = TextEditingController(text: client.name);
    _industryCtrl = TextEditingController(text: client.industry);
    _countryCtrl = TextEditingController(text: client.country);
    _ownerCtrl = TextEditingController(text: client.owner);
    _websiteCtrl = TextEditingController(text: client.website);
    _notesCtrl = TextEditingController(text: client.notes);
    _contactNameCtrl = TextEditingController(text: primary?.name ?? '');
    _contactEmailCtrl = TextEditingController(text: primary?.email ?? '');
    _contactPhoneCtrl = TextEditingController(text: primary?.phone ?? '');
    _contactDesignationCtrl =
        TextEditingController(text: primary?.designation ?? '');
    _status = client.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _industryCtrl.dispose();
    _countryCtrl.dispose();
    _ownerCtrl.dispose();
    _websiteCtrl.dispose();
    _notesCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactDesignationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _contactNameCtrl.text.trim().isEmpty ||
        _contactEmailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Client name, contact name, and contact email are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final client = widget.summary.client;
    try {
      await CrmApi.instance.updateClient(client.id, {
        'name': _nameCtrl.text.trim(),
        'industry': _industryCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'owner': _ownerCtrl.text.trim(),
        'status': _status,
        'website': _websiteCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'health': client.health,
        'activity': client.activity,
        'avatar': client.avatar,
        'primaryContactName': _contactNameCtrl.text.trim(),
        'primaryContactEmail': _contactEmailCtrl.text.trim(),
        'primaryContactPhone': _contactPhoneCtrl.text.trim(),
        'primaryContactDesignation': _contactDesignationCtrl.text.trim(),
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
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Edit Client',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 18),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Company Name')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _industryCtrl, decoration: const InputDecoration(labelText: 'Industry'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _countryCtrl, decoration: const InputDecoration(labelText: 'Country'))),
            ]),
            const SizedBox(height: 12),
            TextField(controller: _ownerCtrl, decoration: const InputDecoration(labelText: 'Account Owner')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: ['Active', 'At Risk', 'Inactive'].contains(_status) ? _status : 'Active',
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Active', 'At Risk', 'Inactive']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(controller: _websiteCtrl, decoration: const InputDecoration(labelText: 'Existing Website')),
            const SizedBox(height: 12),
            TextField(controller: _notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 18),
            const Text('Primary Contact',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 12),
            TextField(controller: _contactNameCtrl, decoration: const InputDecoration(labelText: 'Contact Name')),
            const SizedBox(height: 12),
            TextField(controller: _contactEmailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Contact Email')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _contactPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _contactDesignationCtrl, decoration: const InputDecoration(labelText: 'Designation'))),
            ]),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Client'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddContactSheet extends StatefulWidget {
  final String clientId;

  const _AddContactSheet({required this.clientId});

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _nameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _primary = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Contact name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CrmApi.instance.addClientContact(widget.clientId, {
        'name': _nameCtrl.text.trim(),
        'designation': _designationCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'primaryContact': _primary,
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
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Add Contact',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800)),
            const SizedBox(height: 18),
            TextField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Contact Name')),
            const SizedBox(height: 12),
            TextField(
                controller: _designationCtrl,
                decoration:
                    const InputDecoration(labelText: 'Designation')),
            const SizedBox(height: 12),
            TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _primary,
              onChanged: (value) => setState(() => _primary = value),
              title: const Text('Primary contact'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style:
                      const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
