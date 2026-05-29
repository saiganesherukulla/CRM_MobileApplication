part of 'clients_screen.dart';

class _AddClientSheetState extends State<_AddClientSheet> {
  final _nameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactDesignationCtrl = TextEditingController();
  String _industry = 'Information Technology';
  String _country = 'India';
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
  void dispose() {
    _nameCtrl.dispose();
    _websiteCtrl.dispose();
    _revenueCtrl.dispose();
    _ownerCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactDesignationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Company name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final canViewFinancials = CrmApi.instance.canViewFinancials();
      await CrmApi.instance.createClient({
        'name': _nameCtrl.text.trim(),
        'industry': _industry,
        'country': _country,
        'website': _websiteCtrl.text.trim(),
        'owner': _ownerCtrl.text.trim(),
        if (canViewFinancials)
          'revenue': num.tryParse(
                  _revenueCtrl.text.replaceAll(',', '').replaceAll('\$', '')) ??
              0,
        'contactName': _contactNameCtrl.text.trim(),
        'contactEmail': _contactEmailCtrl.text.trim(),
        'contactPhone': _contactPhoneCtrl.text.trim(),
        'contactDesignation': _contactDesignationCtrl.text.trim(),
        'status': 'Active',
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
    final canViewFinancials = CrmApi.instance.canViewFinancials();
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
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text('Add New Client',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800))
              ]),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Field(
                      label: 'Company Name',
                      hint: 'e.g. Acme Corporation',
                      controller: _nameCtrl),
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
                  if (canViewFinancials)
                    _Field(
                        label: 'Client Service Value',
                        hint: 'e.g. 100000',
                        controller: _revenueCtrl,
                        keyboardType: TextInputType.number),
                  _Field(
                      label: 'Account Owner',
                      hint: 'Owner name',
                      controller: _ownerCtrl),
                  _Field(
                      label: 'Existing Website (optional)',
                      hint: 'https://company.com',
                      controller: _websiteCtrl,
                      keyboardType: TextInputType.url),
                  const SizedBox(height: 4),
                  const Text('Primary Contact',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800)),
                  const SizedBox(height: 10),
                  _Field(
                      label: 'Contact Name',
                      hint: 'e.g. Priya Sharma',
                      controller: _contactNameCtrl),
                  _Field(
                      label: 'Contact Email',
                      hint: 'e.g. priya@company.com',
                      controller: _contactEmailCtrl,
                      keyboardType: TextInputType.emailAddress),
                  _Field(
                      label: 'Contact Phone',
                      hint: 'e.g. +91 98765 43210',
                      controller: _contactPhoneCtrl,
                      keyboardType: TextInputType.phone),
                  _Field(
                      label: 'Designation',
                      hint: 'e.g. Founder',
                      controller: _contactDesignationCtrl),
                  if (_error != null) ...[
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12)),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Client'),
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
