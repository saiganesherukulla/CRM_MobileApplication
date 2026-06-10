part of 'clients_screen.dart';

class _AddClientSheetState extends State<_AddClientSheet> {
  final _nameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactDesignationCtrl = TextEditingController();
  final _initialPasswordCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _industry = 'Information Technology';
  String _country = 'India';
  String _status = 'Active';
  bool _subscriptionActive = false;
  bool _saving = false;
  String? _error;

  static const _industries = [
    'Information Technology',
    'Software',
    'Digital Services',
    'Healthcare Services',
    'Food Manufacturing',
    'EdTech',
    'Logistics',
    'Finance',
    'Retail',
    'Other',
  ];

  static const _countries = [
    'India',
    'United States',
    'United Arab Emirates',
    'United Kingdom',
    'Canada',
    'Australia',
    'Singapore',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    if (lead == null) return;
    _nameCtrl.text = lead.name;
    _websiteCtrl.text = lead.website;
    _ownerCtrl.text = lead.owner;
    _contactNameCtrl.text = lead.contactName;
    _contactEmailCtrl.text = lead.contactEmail;
    _contactPhoneCtrl.text = lead.contactPhone;
    _contactDesignationCtrl.text = lead.contactDesignation;
    _notesCtrl.text = lead.notes;
    if (_industries.contains(lead.industry)) _industry = lead.industry;
    if (_countries.contains(lead.country)) _country = lead.country;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _websiteCtrl.dispose();
    _ownerCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactDesignationCtrl.dispose();
    _initialPasswordCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final isClientUser = CrmApi.instance.isClientUser;
    if (_nameCtrl.text.trim().isEmpty ||
        _contactNameCtrl.text.trim().isEmpty ||
        _contactEmailCtrl.text.trim().isEmpty) {
      setState(() => _error =
          'Company name, contact name, and contact email are required.');
      return;
    }
    if (!CrmApi.instance.canCreateClients) {
      setState(() => _error = 'A subscription is required to add clients.');
      return;
    }
    if (!isClientUser && _initialPasswordCtrl.text.trim().length < 8) {
      setState(
          () => _error = 'Initial password must be at least 8 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'industry': _industry,
        'country': _country,
        'website': _websiteCtrl.text.trim(),
        'owner': _ownerCtrl.text.trim(),
        'contactName': _contactNameCtrl.text.trim(),
        'contactEmail': _contactEmailCtrl.text.trim(),
        'contactPhone': _contactPhoneCtrl.text.trim(),
        'contactDesignation': _contactDesignationCtrl.text.trim(),
        'status': _status,
        'notes': _notesCtrl.text.trim(),
        if (!isClientUser) ...{
          'initialPassword': _initialPasswordCtrl.text.trim(),
          'subscriptionActive': _subscriptionActive,
        },
      };
      if (widget.lead == null) {
        await CrmApi.instance.createClient(payload);
      } else {
        await CrmApi.instance.convertLead(widget.lead!.id, payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClientUser = CrmApi.instance.isClientUser;
    final canCreateClients = CrmApi.instance.canCreateClients;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    widget.lead == null
                        ? 'Add New Client'
                        : 'Convert Lead to Client',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (!canCreateClients) ...[
                    const Text(
                      'A subscription is required before you can add clients.',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _Field(
                    label: 'Company Name',
                    hint: 'e.g. Acme Corporation',
                    controller: _nameCtrl,
                  ),
                  _DropdownField(
                    label: 'Status',
                    value: _status,
                    options: const ['New', 'Active', 'At Risk', 'Inactive'],
                    onChanged: (value) =>
                        setState(() => _status = value ?? _status),
                  ),
                  _DropdownField(
                    label: 'Industry',
                    value: _industry,
                    options: _industries,
                    onChanged: (value) =>
                        setState(() => _industry = value ?? _industry),
                  ),
                  _DropdownField(
                    label: 'Country',
                    value: _country,
                    options: _countries,
                    onChanged: (value) =>
                        setState(() => _country = value ?? _country),
                  ),
                  _Field(
                    label: 'Account Owner',
                    hint: 'Owner name',
                    controller: _ownerCtrl,
                  ),
                  _Field(
                    label: 'Existing Website (optional)',
                    hint: 'https://company.com',
                    controller: _websiteCtrl,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Primary Contact',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Field(
                    label: 'Contact Name',
                    hint: 'e.g. Priya Sharma',
                    controller: _contactNameCtrl,
                  ),
                  _Field(
                    label: 'Contact Email',
                    hint: 'e.g. priya@company.com',
                    controller: _contactEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _Field(
                    label: 'Contact Phone',
                    hint: 'e.g. +91 98765 43210',
                    controller: _contactPhoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  _Field(
                    label: 'Designation',
                    hint: 'e.g. Founder',
                    controller: _contactDesignationCtrl,
                  ),
                  _Field(
                    label: 'Notes',
                    hint: 'Initial client notes',
                    controller: _notesCtrl,
                  ),
                  if (!isClientUser) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Client Login',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Initial Password',
                      hint: 'Temporary password',
                      controller: _initialPasswordCtrl,
                      obscureText: true,
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _subscriptionActive,
                      title: const Text('Enable subscription'),
                      subtitle: const Text(
                        'Allows this client login to add its own clients.',
                      ),
                      onChanged: (value) =>
                          setState(() => _subscriptionActive = value),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: _saving || !canCreateClients ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.lead == null
                                ? 'Save Client'
                                : 'Convert and Create Client',
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
